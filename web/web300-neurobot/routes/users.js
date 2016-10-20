var express = require('express');
var router = express.Router();
var User = require('../models/user');

function setSession(req, user){
  req.session.id = user._id;
  req.session.login = user.login;
  req.session.api_token = user.api_token;
}

router.use(function(req, res, next){
    if(req.session.login){
      res.redirect('/');
      return;
    }
    next();
});

router.get('/log-reg', function(req, res, next) {
  res.render('log-reg', {
    title: 'Chat - Login and Registration',
    login: '',
    message: ''
  });
});

router.post('/log-reg', function(req, res, next) {
  User.findOne({"login":req.body.login}, function(err, user){
    if (err) {
      console.log('User find error!', err);
      res.redirect('/');
      return;
    }

    if(user){
      if(user.password == user.encryptPassword(req.body.password)){
        setSession(req, user);
        res.redirect('/');
      } else {
        res.render('log-reg', {
          title: 'Chat - Login and Registration',
          login: req.body.login,
          message: 'Password is incorrect'
        });
      }
    } else {
      user = new User({
        login: req.body.login,
        password: req.body.password,
        created_at: new Date()
      });

      user.save(function(err, model, affected) {
        if (err) {
          console.log('User save error!', err);
          res.render('log-reg', {
            title: 'Chat - Login and Registration',
            login: req.body.login,
            message: err.toString()
          });
          return;
        }
        setSession(req, user);
        res.redirect('/');
      });
    }


  });
});

module.exports = router;