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
  age: {
    type: Number,
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
    enum: ['single', 'married', 'divorced', 'divorced with kids', 'widowed', 'widowed with kids', 'separated', 'separated with kids', 'single parent', 'prefer_not_to_say'],
    default: 'prefer_not_to_say'
  },
  lookingFor: {
    type: String,
    enum: [
      'Non-committal relationship', 
      'Casual relationship, but exclusive',
      'Casual now, long-term relation later',
      'New friends', 
      'Friendship, open to dating', 
      'Dating', 
      'Dating, eading to marriage',
      'Marriage, open to dating',
      'Long-term relationship',
      'Long-term, fine with short',
      'Fine with both long-term and short-term',
      'Open relationship',
      'Online companion',
      'prefer_not_to_say'
    ],
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
    enum: ['never', 'rarely', 'socially', 'frequently', 'prefer_not_to_say'],
    default: 'prefer_not_to_say'
  },
  smoking: {
    type: String,
    enum: ['never', 'occasionally', 'regularly', 'trying_to_quit', 'prefer_not_to_say'],
    default: 'prefer_not_to_say'
  },
  diet: {
    type: String,
    enum: ['vegetarian', 'vegan', 'non_vegetarian', 'prefer_not_to_say'],
    default: 'prefer_not_to_say'
  },
  zodiacSign: {
    type: String,
    enum: ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces']
  },
  languages: [{
    type: String,
    trim: true
  }]
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