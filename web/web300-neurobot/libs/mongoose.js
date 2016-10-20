var mongoose = require('mongoose');

mongoose.connect('mongodb://127.0.0.1/chat');

module.exports = mongoose;