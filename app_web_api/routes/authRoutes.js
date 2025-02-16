const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth')
const {
  registerUser,
  loginUser,
  getProfile,
  updateProfile,
  sendOTP,
  verifyOTP
} = require('../controllers/authController');

router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/send-otp', sendOTP);
router.post('/verify-otp', verifyOTP);
router.get('/profile', protect, getProfile);
router.put('/profile', protect, updateProfile);

module.exports = router;