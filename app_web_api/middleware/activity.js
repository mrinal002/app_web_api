const User = require('../models/User');

const trackActivity = async (req, res, next) => {
  if (req.user) {
    try {
      await User.findByIdAndUpdate(req.user._id, {
        lastActive: new Date()
      });
    } catch (error) {
      console.error('Activity tracking error:', error);
    }
  }
  next();
};

module.exports = trackActivity;
