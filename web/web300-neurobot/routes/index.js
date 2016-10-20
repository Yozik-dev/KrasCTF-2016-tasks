var express = require('express');
var router = express.Router();
var Message = require('../models/message');
var Purifier = require('html-purify');
var purifier = new Purifier();

router.get('/', function (req, res, next) {
    res.render('index', {title: 'Chat', session: req.session});
});

router.post('/message', function (req, res, next) {
    var date = new Date();
    var mess = new Message({
        user_from: req.session.login,
        message: purifier.purify(req.body.message),
        created_at: date - date.getMilliseconds()
    });

    mess.save(function (err, model, affected) {
        if (err) {
            console.log('Message save error!', err);
            res.send({"status": false});
            return;
        }
        res.send({"status": true, "message": model.message, "created_at": model.created_at});
    });
});

router.get('/time', function (req, res, next) {
    res.send({time: new Date()});
});

router.get('/listen', function (req, res, next) {
    var date = new Date(req.query.date);
    var ttl = 0;
    function longPoll() {
        if(ttl++ > 5*60){
            res.send({"status": true, messages: []});
            return;
        }
        Message.find(
            {"user_to": {$in: [null, req.session.login]}, "created_at": {$gt: date}},
            function (err, models) {
                if (err) {
                    res.send({"status": false});
                    return;
                }
                if(models.length) {
                    res.send({"status": true, messages: models});
                } else {
                    setTimeout(longPoll, 200);
                }
            });
    }
    longPoll();

});


module.exports = router;
