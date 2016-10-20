var url = require('url');
var MongoClient = require('mongodb').MongoClient;

function onRequest(req, res) {
    var pathname = url.parse(req.url).pathname;
    console.log("Request for " + pathname + " received.");
    switch(pathname) {
        case '/message' : actionReciever(req, res, sendMessage); break;
        case '/set-support' : actionReciever(req, res, sendSupport); break;
        case '/get-support' : actionReciever(req, res, viewSupport); break;
        case '/helper' : actionReciever(req, res, setHelper); break;
        default : notFound(req, res);
    }
}

function actionReciever(req, res, callback) {
    var data = '';
    req.on('data', function(chunk) {
        data += chunk.toString();
        if(data.length > 20000){
            res.statusCode = 413;
            res.end();
            return;
        }
    });
    req.on('end', function() {
        try {
            data = JSON.parse(data, function(k, v) {
                if(k) { return typeof v === 'object' ? undefined : v; } else { return v; }
            });
        } catch (e) {
            res.statusCode = 415;
            res.end();
            return;
        }
        if(!data.api_token){
            res.statusCode = 403;
            res.end();
            return;
        }
        MongoClient.connect("mongodb://localhost:27017/chat", function(err, db) {
            if(err){
                res.statusCode = 500;
                res.end();
                return;
            }
            var users = db.collection('users');
            users.find({"api_token":data.api_token}).toArray(function(err, users){
                if(err || users.length == 0) {
                    res.statusCode = 403;
                    res.end();
                    return;
                }
                data.login = users[0].login;
                data.is_admin = users[0].is_admin;
                callback(res, data, db);
            });
        });
    });
}

function sendMessage(res, data, db) {
    var messages = db.collection('messages');
    var date = new Date();

    messages.insertOne({
        user_from: data.login,
        message: data.message,
        created_at: new Date(date - date.getMilliseconds()),
        user_to: data.user_to
    }, function (err, result) {
        if (err) {
            res.statusCode = 500;
            res.end();
            return;
        }
        res.statusCode = 201;
        res.end();
    });
}

function sendSupport(res, data, db) {
    var support = db.collection('support');
    var date = new Date();

    support.insertOne({
        user_from: data.login,
        message: data.message,
        created_at: new Date(date - date.getMilliseconds()),
    }, function (err, result) {
        if (err) {
            res.statusCode = 500;
            res.end();
            return;
        }
        res.statusCode = 201;
        res.end();
    });
}

function viewSupport(res, data, db) {
    if(!data.is_admin){
        res.statusCode = 403;
        res.end();
        return;
    }
    var support = db.collection('support');

    support.find().toArray(function (err, results) {
        if (err) {
            res.statusCode = 500;
            res.end();
            return;
        }
        res.statusCode = 200;
        res.end(encJSON(results));
    });
}

function setHelper(res, data, db) {
    if(!data.is_admin){
        res.statusCode = 403;
        res.end();
        return;
    }
    var users = db.collection('users');

    users.updateOne({login:data.user_to}, {$set: {is_admin:true}}, function (err, model) {
        if(err){
            res.statusCode = 500;
            res.end();
            return;
        }
        if(model.result.nModified) {
            res.statusCode = 202;
            res.end();
        } else {
            res.statusCode = 422;
            res.end();
        }
    });
}

function notFound(req, res) {
    res.statusCode = 404;
    res.end();
}

function encJSON(data) {
    return JSON.stringify(data);
}

console.log("API Server started...");

module.exports = onRequest;