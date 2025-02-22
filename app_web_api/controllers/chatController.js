const Chat = require('../models/Chat');
const User = require('../models/User');
const asyncHandler = require('express-async-handler');

// Get chat history with a specific user
const getChatHistory = asyncHandler(async (req, res) => {
  const { userId } = req.params;
  const currentUserId = req.user.id;

  const messages = await Chat.find({
    $or: [
      { sender: currentUserId, receiver: userId },
      { sender: userId, receiver: currentUserId }
    ]
  })
  .sort({ createdAt: 1 })
  .populate('sender', 'name profilePicture')
  .populate('receiver', 'name profilePicture');

  res.json({
    success: true,
    messages
  });
});

// Get recent chat list
const getRecentChats = asyncHandler(async (req, res) => {
  const currentUserId = req.user.id;

  const recentChats = await Chat.aggregate([
    {
      $match: {
        $or: [
          { sender: currentUserId },
          { receiver: currentUserId }
        ]
      }
    },
    {
      $sort: { createdAt: -1 }
    },
    {
      $group: {
        _id: {
          $cond: [
            { $eq: ['$sender', currentUserId] },
            '$receiver',
            '$sender'
          ]
        },
        lastMessage: { $first: '$message' },
        unreadCount: {
          $sum: {
            $cond: [
              { 
                $and: [
                  { $eq: ['$receiver', currentUserId] },
                  { $eq: ['$read', false] }
                ]
              },
              1,
              0
            ]
          }
        },
        lastMessageAt: { $first: '$createdAt' }
      }
    }
  ]);

  // Get user details for each chat
  const populatedChats = await User.populate(recentChats, {
    path: '_id',
    select: 'name profilePicture isOnline lastActive'
  });

  res.json({
    success: true,
    chats: populatedChats
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

// Send message
const sendMessage = asyncHandler(async (req, res) => {
  const { receiverId, message } = req.body;
  const senderId = req.user.id;

  if (!receiverId || !message) {
    res.status(400);
    throw new Error('Receiver ID and message are required');
  }

  // Create new chat message
  const chat = await Chat.create({
    sender: senderId,
    receiver: receiverId,
    message
  });

  // Populate sender and receiver details
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
});

module.exports = {
  getChatHistory,
  getRecentChats,
  markMessagesAsRead,
  sendMessage
};
