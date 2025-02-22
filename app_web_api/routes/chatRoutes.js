const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  getChatHistory,
  getRecentChats,
  markMessagesAsRead,
  sendMessage
} = require('../controllers/chatController');

router.get('/history/:userId', protect, getChatHistory);
router.get('/recent', protect, getRecentChats);
router.put('/read/:senderId', protect, markMessagesAsRead);
router.post('/send', protect, sendMessage);

module.exports = router;
