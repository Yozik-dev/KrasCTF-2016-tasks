var mongoose = require('../libs/mongoose'),
    Schema = mongoose.Schema;

var messageSchema = new Schema({
    user_from: String,
    user_to: {
        type: String,
        default: null
    },
    message: String,
    created_at: Date
});

module.exports = mongoose.model('Message', messageSchema);