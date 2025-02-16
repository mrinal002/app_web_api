const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const asyncHandler = require('express-async-handler');
const admin = require('../config/firebase');

// Add phone number validation helper
const validatePhoneNumber = (phoneNumber) => {
  const phoneRegex = /^\+[1-9]\d{10,14}$/;
  return phoneRegex.test(phoneNumber);
};

// @desc    Register user
// @route   POST /api/auth/register
// @access  Public
const registerUser = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  
  // Check if user exists
  const userExists = await User.findOne({ email });
  if (userExists) {
    res.status(400);
    throw new Error('User already exists');
  }

  // Create user
  const user = await User.create({ email, password });

  // Generate token
  const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
    expiresIn: '30d'
  });

  res.status(201).json({
    _id: user._id,
    email: user.email,
    token
  });
});

// @desc    Send OTP
// @route   POST /api/auth/send-otp
// @access  Public
const sendOTP = asyncHandler(async (req, res) => {
  const { phoneNumber } = req.body;

  if (!phoneNumber) {
    return res.status(400).json({ 
      success: false,
      error: 'Phone number is required' 
    });
  }

  if (!validatePhoneNumber(phoneNumber)) {
    return res.status(400).json({ 
      success: false,
      error: 'Invalid phone number format. Use format: +[country code][number]' 
    });
  }

  try {
    // Verify Firebase Admin is working
    await admin.app().get();

    // Check if user already exists with this phone number
    const existingUser = await User.findOne({ mobileNumber: phoneNumber });
    
    // Generate a random 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Store OTP in memory (use Redis in production)
    global.otpMap = global.otpMap || new Map();
    
    const otpData = {
      otp,
      timestamp: Date.now(),
      attempts: 0,
      verified: false
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
    
    if (!user) {
      user = await User.create({
        mobileNumber: phoneNumber,
        password: Math.random().toString(36).slice(2),
        isVerified: true
      });
    } else {
      user.isVerified = true;
      await user.save();
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

  // Check for user by email or mobile
  const user = await User.findOne({
    $or: [
      { email: emailOrMobile },
      { mobileNumber: emailOrMobile }
    ]
  });
  
  if (user && (await bcrypt.compare(password, user.password))) {
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: '30d'
    });
    
    res.json({
      _id: user._id,
      email: user.email,
      mobileNumber: user.mobileNumber,
      token
    });
  } else {
    res.status(401);
    throw new Error('Invalid credentials');
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
      email: user.email
    });
  } else {
    res.status(404);
    throw new Error('User not found');
  }
});

// @desc    Update user profile
// @route   PUT /api/auth/profile
// @access  Private
const updateProfile = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id);

  if (user) {
    user.email = req.body.email || user.email;
    if (req.body.password) {
      user.password = req.body.password;
    }

    const updatedUser = await user.save();

    res.json({
      _id: updatedUser._id,
      email: updatedUser.email,
      token: jwt.sign({ id: updatedUser._id }, process.env.JWT_SECRET, {
        expiresIn: '30d'
      })
    });
  } else {
    res.status(404);
    throw new Error('User not found');
  }
});

module.exports = {
  registerUser,
  loginUser,
  getProfile,
  updateProfile,
  sendOTP,
  verifyOTP
};