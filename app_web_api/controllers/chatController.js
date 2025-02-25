const Chat = require('../models/Chat');
const User = require('../models/User');
const Conversation = require('../models/Conversation');
const asyncHandler = require('express-async-handler');

// Get chat history with a specific user
const getChatHistory = asyncHandler(async (req, res) => {
  const { conversationId } = req.params;
  const currentUserId = req.user.id;

  const conversation = await Conversation.findOne({
    _id: conversationId,
    participants: currentUserId
  });
   console.log(conversation)  
  if (!conversation) {
    res.status(404);
    throw new Error('Conversation not found');
  }

  const messages = await Chat.find({ conversation: conversationId })
    .sort({ createdAt: 1 })
    .populate('sender', 'name profilePicture')
    .populate('receiver', 'name profilePicture');

  res.json({
    success: true,
    messages
  });
});

// Get recent conversations
const getRecentChats = asyncHandler(async (req, res) => {
  const currentUserId = req.user.id;

  const conversations = await Conversation.find({
    participants: currentUserId
  })
    .sort({ lastMessageTime: -1 })
    .populate('participants', 'name profilePicture isOnline lastActive');

  res.json({
    success: true,
    conversations
  });
});

// Mark messages as read
const markMessagesAsRead = asyncHandler(async (req, res) => {
  const { senderId } = req.params;
  const currentUserId = req.user.id;

  await Chat.updateMany(
    {
      sender: senderId,
      receiver: currentUserId,
      read: false
    },
    {
      read: true
    }
  );

  res.json({
    success: true,
    message: 'Messages marked as read'
  });
});

const sendMessage = asyncHandler(async (req, res) => {
  const { receiverId, message } = req.body;
  const senderId = req.user.id;

  if (!receiverId || !message) {
    res.status(400);
    throw new Error('Receiver ID and message are required');
  }

  try {
    // Always sort IDs to ensure consistent participant order
    const participantIds = [senderId, receiverId].sort((a, b) => 
      a.localeCompare(b)
    );
    
    // Find existing conversation with exact participant match and order
    let conversation = await Conversation.findOne({
      participants: participantIds
    });

    if (!conversation) {
      // Create new conversation with sorted participants
      conversation = await Conversation.create({
        participants: participantIds
      });
    }

    // Create chat message
    const chat = await Chat.create({
      conversation: conversation._id,
      sender: senderId,
      receiver: receiverId,
      message
    });

    // Update conversation's last message
    await Conversation.findByIdAndUpdate(conversation._id, {
      lastMessage: message,
      lastMessageTime: new Date()
    });

    // Populate message details
    const populatedChat = await Chat.findById(chat._id)
      .populate('sender', 'name profilePicture')
      .populate('receiver', 'name profilePicture');

    // Emit socket event if user is online
    const io = req.app.get('io');
    const receiverSocketId = global.connectedUsers?.get(receiverId);
    if (receiverSocketId) {
      io.to(receiverSocketId).emit('new_message', populatedChat);
    }

    res.status(201).json({
      success: true,
      message: populatedChat
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500);
    throw new Error(`Message sending failed: ${error.message}`);
  }
});

const checkConversation = asyncHandler(async (req, res) => {
  const { userId } = req.params;
  const currentUserId = req.user.id;

  // Sort IDs the same way as in sendMessage
  const participantIds = [currentUserId, userId].sort((a, b) => 
    a.localeCompare(b)
  );

  const conversation = await Conversation.findOne({
    participants: participantIds
  });

  res.json({
    success: true,
    conversationId: conversation ? conversation._id : null
  });
});

const getUserConversationIds = asyncHandler(async (req, res) => {
  const currentUserId = req.user.id;

  const conversations = await Conversation.find({
    participants: currentUserId
  })
    .select('_id lastMessage lastMessageTime participants')
    .populate('participants', 'name _id')
    .sort({ lastMessageTime: -1 });

  const conversationDetails = conversations.map(conv => ({
    conversationId: conv._id,
    lastMessage: conv.lastMessage,
    lastMessageTime: conv.lastMessageTime,
    participants: conv.participants.map(p => ({
      id: p._id,
      name: p.name
    }))
  }));

  res.json({
    success: true,
    conversations: conversationDetails
  });
});

module.exports = {
  getChatHistory,
  getRecentChats,
  markMessagesAsRead,
  sendMessage,
  checkConversation,
  getUserConversationIds
};
