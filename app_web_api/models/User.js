const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    unique: true,
    sparse: true,
    lowercase: true,
    trim: true
  },
  gender:{
    type: String,
    required: true,
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  dateOfBirth: {
    type: Date,
    required: true
  },
  name: {
    type: String,
    trim: true,
    required: true,
  },
  mobileNumber: {
    type: String,
    unique: true,
    sparse: true,
    trim: true
  },

  facebookId: {
    type: String,
    unique: true,
    sparse: true
  },
  facebookLink: {
    type: String
  },
  facebookAlbums: [{
    albumId: String,
    photos: [{
      imageUrl: String,
      height: Number,
      width: Number
    }]
  }],

  profilePicture: {
    type: String
  },
  // VerifiedPhoto user's photo for selfe verification
  VerifiedPhoto:{
    type: String
  },
  // Update verification fields
  isMobileVerified: {
    type: Boolean,
    default: false
  },
  isFacebookVerified: {
    type: Boolean,
    default: false
  },
  isPhotoVerified: {
    type: Boolean,
    default: false
  },

  // Profile fields

  aboutMe: {
    type: String,
    maxlength: 500
  },
  city: {
    type: String,
    trim: true
  },
  relationshipStatus: {
    type: String,
    default: 'prefer_not_to_say'
  },
  lookingFor: {
    type: String,
    default: 'prefer_not_to_say'
  },
  interests: [{
    type: String,
    trim: true
  }],
  education: {
    type: String,
    trim: true
  },
  profession: {
    type: String,
    trim: true
  },
  drinking: {
    type: String,
    default: 'prefer_not_to_say'
  },
  smoking: {
    type: String,
    default: 'prefer_not_to_say'
  },
  diet: {
    type: String,
    default: 'prefer_not_to_say'
  },
  zodiacSign: {
    type: String,
  },
  languages: [{
    type: String,
    trim: true
  }],
  isOnline: {
    type: Boolean,
    default: false
  },
  lastActive: {
    type: Date,
    default: Date.now
  },
  socketId: {
    type: String,
    default: null
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});



// Hash password before saving
userSchema.pre('save', async function(next) {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 10);
  }
  next();
});

module.exports = mongoose.model('User', userSchema);