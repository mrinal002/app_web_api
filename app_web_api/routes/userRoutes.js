const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  getOnlineUsers,
  getPotentialChatUsers
} = require('../controllers/userController');

router.get('/online', protect, getOnlineUsers);
router.get('/chat-users', protect, getPotentialChatUsers);

module.exports = router;
