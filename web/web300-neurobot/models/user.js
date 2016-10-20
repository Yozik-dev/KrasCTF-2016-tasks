var mongoose = require('../libs/mongoose'),
    Schema = mongoose.Schema;
var SHA = require('crypto-js/sha384');
var randomstring = require("randomstring");

var userSchema = new Schema({
    login: {
        type:String,
        required: true,
        unique: true
    },
    password: {
        type:String,
        required: true
    },
    is_admin: {
        type: Boolean,
        default: false
    },
    api_token: {
        type: String
    },
    created_at: Date
});
userSchema.methods.encryptPassword = function (password) {
    return SHA(password)
};
userSchema.pre('save', function (next) {
    this.password = this.encryptPassword(this.password);
    this.api_token = randomstring.generate(20);
    next();
});

module.exports = mongoose.model('User', userSchema);