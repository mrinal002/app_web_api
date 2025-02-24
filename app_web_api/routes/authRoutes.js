const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth')
const {
  registerUser,
  loginUser,
  getProfile,
  updateProfile,
  sendOTP,
  verifyOTP,
  facebookLogin,
  profilefacebookLogin,
  logout
} = require('../controllers/authController');

router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/logout', protect, logout);
router.post('/send-otp', sendOTP);
router.post('/verify-otp', verifyOTP);
router.post('/facebook', facebookLogin);
router.post('/profile-facebook',protect, profilefacebookLogin);
router.get('/profile', protect, getProfile);
router.put('/profile', protect, updateProfile);

module.exports = router;