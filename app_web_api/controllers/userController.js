const User = require('../models/User');
const asyncHandler = require('express-async-handler');

// Get all online users
const getOnlineUsers = asyncHandler(async (req, res) => {
  const onlineUsers = await User.find({ 
    isOnline: true,
    _id: { $ne: req.user.id } // Exclude current user
  }).select('name profilePicture lastActive');

  res.json({
    success: true,
    users: onlineUsers
  });
});

// Get user's matches or potential chat partners
const getPotentialChatUsers = asyncHandler(async (req, res) => {
  const users = await User.find({
    _id: { $ne: req.user.id }
  })
  .select('name profilePicture isOnline lastActive')
  .sort({ isOnline: -1, lastActive: -1 })
  .limit(20);

  res.json({
    success: true,
    users
  });
});

module.exports = {
  getOnlineUsers,
  getPotentialChatUsers
};
