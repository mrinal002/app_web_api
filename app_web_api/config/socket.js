const User = require('../models/User');
const Chat = require('../models/Chat');
const jwt = require('jsonwebtoken');

let connectedUsers = new Map();

const socketConfig = (io) => {
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      if (!token) {
        throw new Error('Authentication error');
      }
      
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.userId = decoded.id;
      next();
    } catch (err) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', async (socket) => {
    console.log('User connected:', socket.userId);
    
    // Add user to connected users and update status
    connectedUsers.set(socket.userId, socket.id);
    await User.findByIdAndUpdate(socket.userId, { 
      isOnline: true, 
      lastActive: new Date(),
      socketId: socket.id
    });
    
    // Broadcast updated online users list
    const onlineUsers = await User.find({ 
      isOnline: true 
    }).select('_id name profilePicture');
    io.emit('users_online', onlineUsers);

    // Broadcast user's online status
    socket.broadcast.emit('userStatus', {
      userId: socket.userId,
      isOnline: true
    });

    // Handle private messages
    socket.on('private_message', async (data) => {
      try {
        const { receiverId, message } = data;
        
        // Store message in database
        const chat = await Chat.create({
          sender: socket.userId,
          receiver: receiverId,
          message
        });

        // Populate sender details
        const populatedChat = await Chat.findById(chat._id)
          .populate('sender', 'name profilePicture')
          .populate('receiver', 'name profilePicture');

        // Send to receiver if online
        const receiverSocket = connectedUsers.get(receiverId);
        if (receiverSocket) {
          io.to(receiverSocket).emit('new_message', populatedChat);
        }

        // Send confirmation to sender
        socket.emit('message_sent', populatedChat);
      } catch (error) {
        socket.emit('message_error', { error: 'Failed to send message' });
      }
    });

    // Handle typing status with debounce
    let typingTimeout;
    socket.on('typing', (data) => {
      const receiverSocket = connectedUsers.get(data.receiverId);
      if (receiverSocket) {
        io.to(receiverSocket).emit('user_typing', {
          userId: socket.userId,
          isTyping: data.isTyping
        });

        // Clear typing status after 2 seconds
        clearTimeout(typingTimeout);
        typingTimeout = setTimeout(() => {
          io.to(receiverSocket).emit('user_typing', {
            userId: socket.userId,
            isTyping: false
          });
        }, 2000);
      }
    });

    // Handle disconnect
    socket.on('disconnect', async () => {
      console.log('User disconnected:', socket.userId);
      connectedUsers.delete(socket.userId);
      
      // Update user status
      await User.findByIdAndUpdate(socket.userId, { 
        isOnline: false, 
        lastActive: new Date(),
        socketId: null
      });

      // Broadcast updated online users list
      const onlineUsers = await User.find({ 
        isOnline: true 
      }).select('_id name profilePicture');
      io.emit('users_online', onlineUsers);

      // Broadcast user's offline status
      socket.broadcast.emit('userStatus', {
        userId: socket.userId,
        isOnline: false
      });
    });
  });
};

module.exports = socketConfig;
