const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  getChatHistory,
  getRecentChats,
  markMessagesAsRead,
  sendMessage,
  checkConversation,
  getUserConversationIds
} = require('../controllers/chatController');

router.get('/history/:conversationId', protect, getChatHistory);
router.get('/recent', protect, getRecentChats);
router.put('/read/:senderId', protect, markMessagesAsRead);
router.post('/send', protect, sendMessage);
router.get('/check-conversation/:userId', protect, checkConversation);
router.get('/conversations/ids', protect, getUserConversationIds);

module.exports = router;
