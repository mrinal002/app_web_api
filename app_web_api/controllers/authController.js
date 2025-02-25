const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const asyncHandler = require('express-async-handler');
const admin = require('../config/firebase');
const axios = require('axios');

// Add helper functions
const validatePhoneNumber = (phoneNumber) => {
  const phoneRegex = /^\+[1-9]\d{10,14}$/;
  return phoneRegex.test(phoneNumber);
};



// @desc    Register user
// @route   POST /api/auth/register
// @access  Public
const registerUser = asyncHandler(async (req, res) => {
  const { email, gender, password, dateOfBirth,name } = req.body;
  
  // Validate required fields
  if (!email || !gender || !password || !dateOfBirth || !name) {
    res.status(400);
    throw new Error('Please provide all required fields');
  }


  

  // Check if user exists
  const userExists = await User.findOne({ email });
  if (userExists) {
    res.status(400);
    throw new Error('Email already exists');
  }

  // Store registration data in memory (use Redis in production)
  global.registrationMap = global.registrationMap || new Map();
  global.registrationMap.set(email, {
    email,
    name,
    gender,
    password,
    dateOfBirth,
    timestamp: Date.now()
  });
  console.log('Registration data stored for email:', global.registrationMap.get(email));
  res.status(200).json({
    success: true,
    message: 'Registration data stored. Please verify mobile number.',
    email
  });
});

// @desc    Send OTP
// @route   POST /api/auth/send-otp
// @access  Public
const sendOTP = asyncHandler(async (req, res) => {
  const { phoneNumber, email } = req.body;
  
  if (!phoneNumber || !email) {
    return res.status(400).json({ 
      success: false,
      error: 'Phone number and email are required' 
    });
  }

  // Verify registration data exists
  const registrationData = global.registrationMap.get(email);
  if (!registrationData) {
    return res.status(400).json({
      success: false,
      error: 'Please complete registration first'
    });
  }

  if (!validatePhoneNumber(phoneNumber)) {
    return res.status(400).json({ 
      success: false,
      error: 'Invalid phone number format. Use format: +[country code][number]' 
    });
  }

  try {
    // Verify Firebase Admin is initialized correctly
    if (!admin.apps.length) {
      throw new Error('Firebase Admin not initialized');
    }

    // Instead of get(), use auth() to verify Firebase connection
    await admin.auth().listUsers(1);

    // Check if user already exists with this phone number
    const existingUser = await User.findOne({ mobileNumber: phoneNumber });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        error: 'Phone number is already registered. Please log in instead.'
      });
    }
    
    // Generate a random 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Store OTP in memory (use Redis in production)
    global.otpMap = global.otpMap || new Map();
    
    const otpData = {
      otp,
      timestamp: Date.now(),
      attempts: 0,
      verified: false,
      email // Store email with OTP data
    };
    global.otpMap.set(phoneNumber, otpData);

    // Generate a simple JWT token instead of Firebase custom token
    const tempToken = jwt.sign(
      { 
        phoneNumber,
        type: 'otp_verification'
      }, 
      process.env.JWT_SECRET, 
      { expiresIn: '10m' }
    );
    console.log('OTP generated:', otp);
    console.log('Temporary token:', tempToken);
    
    // In production, you would send the OTP via SMS here
    // For development, we'll return it in the response
    res.json({
      success: true,
      message: 'OTP sent successfully',
      tempToken,
      userExists: !!existingUser,
      // Remove these in production
      debug: {
        otp: otp,
        phoneNumber: phoneNumber
      }
    });

  } catch (error) {
    console.error('Firebase Admin Error:', error);
    res.status(500).json({ 
      success: false,
      error: 'Firebase service is unavailable. Please try again later.',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// @desc    Verify OTP
// @route   POST /api/auth/verify-otp
// @access  Public
const verifyOTP = asyncHandler(async (req, res) => {
  const { phoneNumber, otp, tempToken } = req.body;

  if (!phoneNumber || !otp || !tempToken) {
    res.status(400);
    throw new Error('Phone number, OTP and temporary token are required');
  }

  try {
    // Verify the JWT token
    const decoded = jwt.verify(tempToken, process.env.JWT_SECRET);
    
    if (decoded.phoneNumber !== phoneNumber || decoded.type !== 'otp_verification') {
      throw new Error('Invalid token');
    }

    // Verify the stored OTP
    const storedOTPData = global.otpMap.get(phoneNumber);
    
    if (!storedOTPData) {
      throw new Error('OTP expired or not found');
    }

    if (storedOTPData.attempts >= 3) {
      global.otpMap.delete(phoneNumber);
      throw new Error('Too many attempts. Please request a new OTP');
    }

    if (Date.now() - storedOTPData.timestamp > 300000) { // 5 minutes expiry
      global.otpMap.delete(phoneNumber);
      throw new Error('OTP expired');
    }

    storedOTPData.attempts++;

    if (storedOTPData.otp !== otp) {
      throw new Error('Invalid OTP');
    }

    // Find or create user
    let user = await User.findOne({ mobileNumber: phoneNumber });
    console.log('User found:', user);
    
    if (!user) {
      const storedEmail = storedOTPData.email;
      const registrationData = global.registrationMap.get(storedEmail);

      if (!registrationData) {
        throw new Error('Registration data not found');
      }

      // Create user with registration data
      user = await User.create({
        ...registrationData,
        mobileNumber: phoneNumber,
        isMobileVerified: true
      });
      
      // Clear registration data
      global.registrationMap.delete(storedEmail);
    }

    // Clear OTP data
    global.otpMap.delete(phoneNumber);

    // Generate JWT token
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: '30d'
    });

    res.json({
      success: true,
      message: 'OTP verified successfully',
      user: {
        _id: user._id,
        mobileNumber: user.mobileNumber,
        email: user.email
      },
      token
    });

  } catch (error) {
    console.error('Verification Error:', error);
    res.status(400);
    throw new Error(`Verification failed: ${error.message}`);
  }
});

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
const loginUser = asyncHandler(async (req, res) => {
  const { emailOrMobile, password } = req.body;

  console.log('Login attempt for:', emailOrMobile);

  if (!emailOrMobile || !password) {
    res.status(400);
    throw new Error('Please provide both email/mobile and password');
  }

  // Check for user by email or mobile (case-insensitive)
  const user = await User.findOne({
    $or: [
      { email: emailOrMobile.toLowerCase() },
      { mobileNumber: emailOrMobile }
    ]
  });

  console.log('User found:', user ? 'Yes' : 'No');

  if (!user) {
    res.status(401);
    throw new Error('Invalid email/mobile or password');
  }

  // Verify password
  const isMatch = await bcrypt.compare(password, user.password);
  console.log('Password match:', isMatch ? 'Yes' : 'No');

  if (isMatch) {
    // Update online status and last activity
    user.isOnline = true;
    user.lastActive = new Date();
    user.lastLogin = new Date();
    await user.save();

    // Generate new token
    const token = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      success: true,
      user: {
        _id: user._id,
        email: user.email,
        mobileNumber: user.mobileNumber,
        name: user.name,
        profilePicture: user.profilePicture,
        isOnline: user.isOnline,
        lastActive: user.lastActive,
        lastLogin: user.lastLogin,
        isVerified: user.isMobileVerified || user.isFacebookVerified
      },
      token
    });
  } else {
    res.status(401);
    throw new Error('Invalid email/mobile or password');
  }
});

// @desc    Logout user
// @route   POST /api/auth/logout
// @access  Private
const logout = asyncHandler(async (req, res) => {
  // Update last logout timestamp and online status
  await User.findByIdAndUpdate(req.user.id, {
    lastLogout: new Date(),
    isOnline: false,
    lastActive: new Date(),
    socketId: null
  });

  res.json({
    success: true,
    message: 'Logged out successfully'
  });
});

// @desc    Login/Register with Facebook
// @route   POST /api/auth/facebook
// @access  Public
const facebookLogin = asyncHandler(async (req, res) => {
  const { accessToken } = req.body;

  if (!accessToken) {
    res.status(400);
    throw new Error('Access token is required');
  }

  try {
    // Get user data from Facebook
    const response = await axios.get(
      `https://graph.facebook.com/v12.0/me?fields=name,birthday,email,gender,id,link,albums{photos{images.height(1280).width(720)}}&access_token=${accessToken}`
    );

    const { 
      id: facebookId, 
      name, 
      email,
      birthday,
      gender,
      link,
      albums
    } = response.data;

    console.log('Processing Facebook data for user:', name);

    // Process albums data with strict dimension filtering
    let allPhotos = [];
    albums?.data?.forEach(album => {
      const albumPhotos = album.photos?.data?.map(photo => {
        // Find image with EXACT 1280x720 dimensions only
        const targetImage = photo.images?.find(img => 
          img.height === 1280 && img.width === 720
        );

        if (targetImage) {
          return {
            imageUrl: targetImage.source,
            height: targetImage.height,
            width: targetImage.width
          };
        }
        return null;
      }).filter(photo => photo !== null) || [];
      
      allPhotos = [...allPhotos, ...albumPhotos];
    });

    // Take only first 5 photos that match the dimensions
    allPhotos = allPhotos.slice(0, 5);

    console.log('Found', allPhotos.length, 'photos with exact 1280x720 dimensions');

    const processedAlbums = [{
      albumId: 'combined',
      photos: allPhotos
    }];

    // Try to get profile picture from first matching photo
    const profilePicture = allPhotos[0]?.imageUrl || null;

    // Find user by Facebook ID or email
    let user = await User.findOne({
      $or: [
        { facebookId },
       
      ]
    });

    const isNewUser = !user;
    
    if (!user) {
      user = await User.create({
        facebookId,
        email: email || `${facebookId}@facebook.com`,
        name,
        dateOfBirth: birthday ? new Date(birthday) : undefined,
        
        gender: gender || 'prefer_not_to_say',
        password: await bcrypt.hash(Math.random().toString(36).slice(-8), 10),
        profilePicture,
        facebookLink: link,
        facebookAlbums: processedAlbums,
        isFacebookVerified: true
      });
    } else {
      console.log('Updating user data');
      user.facebookId = facebookId;
      user.name = name || user.name;
      if (birthday) {
        user.dateOfBirth = new Date(birthday);
        
      }
      if (gender) user.gender = gender;
      if (profilePicture) user.profilePicture = profilePicture;
      if (link) user.facebookLink = link;
      user.facebookAlbums = processedAlbums;
      user.isFacebookVerified = true;
      if (email) user.email = email;
      await user.save();
    }

    // Generate JWT token
    const token = jwt.sign(
      { id: user._id }, 
      process.env.JWT_SECRET, 
      { expiresIn: '30d' }
    );

    res.json({
      success: true,
      isNewUser,
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        dateOfBirth: user.dateOfBirth,
        
        gender: user.gender,
        profilePicture: user.profilePicture,
        facebookLink: user.facebookLink,
        albumsCount: user.facebookAlbums?.length || 0,
        totalPhotos: user.facebookAlbums?.reduce((sum, album) => sum + album.photos.length, 0) || 0,
        isFacebookVerified: user.isFacebookVerified
      },
      token
    });

  } catch (error) {
    console.error('Facebook authentication error:', error);
    console.error('Error details:', error.response?.data || 'No additional error details');
    res.status(401).json({
      success: false,
      error: error.response?.data?.error?.message || 'Facebook authentication failed',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// @desc    Get user profile
// @route   GET /api/auth/profile
// @access  Private
const getProfile = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id);
  
  if (user) {
    res.json({
      _id: user._id,
      email: user.email,
      name: user.name,
      gender: user.gender,
      dateOfBirth: user.dateOfBirth,
      
      mobileNumber: user.mobileNumber,
      facebookId: user.facebookId,
      facebookLink: user.facebookLink,
      facebookAlbums: user.facebookAlbums,
      profilePicture: user.profilePicture,
      VerifiedPhoto: user.VerifiedPhoto,
      isMobileVerified: user.isMobileVerified,
      isFacebookVerified: user.isFacebookVerified,
      isPhotoVerified: user.isPhotoVerified,
      aboutMe: user.aboutMe,
      city: user.city,
      relationshipStatus: user.relationshipStatus,
      lookingFor: user.lookingFor,
      interests: user.interests,
      education: user.education,
      profession: user.profession,
      drinking: user.drinking,
      smoking: user.smoking,
      diet: user.diet,
      zodiacSign: user.zodiacSign,
      languages: user.languages,
      isOnline: user.isOnline,
      lastActive: user.lastActive,
      socketId: user.socketId,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt
    });
  } else {
    res.status(404);
    throw new Error('User not found');
  }
});

// @desc    Update user profile with Facebook data
// @route   POST /api/auth/profile/facebook
// @access  Private
const profilefacebookLogin = asyncHandler(async (req, res) => {
  const { accessToken } = req.body;

  if (!accessToken) {
    res.status(400);
    throw new Error('Access token is required');
  }

  try {
    // Get user data from Facebook
    const response = await axios.get(
      `https://graph.facebook.com/v12.0/me?fields=name,birthday,email,gender,id,link,albums{photos{images.height(1280).width(720)}}&access_token=${accessToken}`
    );

    const { 
      id: facebookId, 
      link,
      albums
    } = response.data;

    // Process albums data
    let allPhotos = [];
    albums?.data?.forEach(album => {
      const albumPhotos = album.photos?.data?.map(photo => {
        const targetImage = photo.images?.find(img => 
          img.height === 1280 && img.width === 720
        );

        if (targetImage) {
          return {
            imageUrl: targetImage.source,
            height: targetImage.height,
            width: targetImage.width
          };
        }
        return null;
      }).filter(photo => photo !== null) || [];
      
      allPhotos = [...allPhotos, ...albumPhotos];
    });

    // Take only first 5 photos
    allPhotos = allPhotos.slice(0, 5);

    const processedAlbums = [{
      albumId: 'combined',
      photos: allPhotos
    }];

    // Get profile picture from first matching photo
    const profilePicture = allPhotos[0]?.imageUrl || null;

    // Find and update existing user
    const user = await User.findByIdAndUpdate(
      req.user.id,
      {
        facebookId,
        facebookLink: link,
        facebookAlbums: processedAlbums,
        profilePicture: profilePicture || user.profilePicture,
        isFacebookVerified: true
      },
      { new: true }
    );

    if (!user) {
      res.status(404);
      throw new Error('User not found');
    }

    res.json({
      success: true,
      user: {
        _id: user._id,
        facebookId: user.facebookId,
        facebookLink: user.facebookLink,
        profilePicture: user.profilePicture,
        albumsCount: user.facebookAlbums?.length || 0,
        totalPhotos: user.facebookAlbums?.reduce((sum, album) => sum + album.photos.length, 0) || 0,
        isFacebookVerified: user.isFacebookVerified
      }
    });

  } catch (error) {
    console.error('Facebook data update error:', error);
    res.status(400).json({
      success: false,
      error: 'Failed to update Facebook data',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// @desc    Update user profile
// @route   PUT /api/auth/profile
// @access  Private
const updateProfile = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id);

  if (user) {
    const updateFields = [
      'name', 'aboutMe', 'city', 'relationshipStatus',
      'lookingFor', 'interests', 'education', 'profession',
      'drinking', 'smoking', 'diet', 'zodiacSign', 'languages'
    ];

    updateFields.forEach(field => {
      if (req.body[field] !== undefined) {
        user[field] = req.body[field];
      }
    });

    // Special handling for arrays
    if (req.body.interests) {
      user.interests = Array.isArray(req.body.interests) ? req.body.interests : [req.body.interests];
    }
    if (req.body.languages) {
      user.languages = Array.isArray(req.body.languages) ? req.body.languages : [req.body.languages];
    }

    const updatedUser = await user.save();

    res.json({
      success: true,
      user: {
        _id: updatedUser._id,
        email: updatedUser.email,
        name: updatedUser.name,
        aboutMe: updatedUser.aboutMe,
        city: updatedUser.city,
        relationshipStatus: updatedUser.relationshipStatus,
        lookingFor: updatedUser.lookingFor,
        interests: updatedUser.interests,
        education: updatedUser.education,
        profession: updatedUser.profession,
        drinking: updatedUser.drinking,
        smoking: updatedUser.smoking,
        diet: updatedUser.diet,
        zodiacSign: updatedUser.zodiacSign,
        languages: updatedUser.languages
      }
    });
  } else {
    res.status(404);
    throw new Error('User not found');
  }
});

module.exports = {
  registerUser,
  loginUser,
  logout,
  getProfile,
  updateProfile,
  sendOTP,
  verifyOTP,
  facebookLogin,
  profilefacebookLogin,
};