var express = require('express');
var favicon = require('serve-favicon');
var logger = require('morgan');
var bodyParser = require('body-parser');
var hashString = require('./libs/hash.js');

var routes = require('./routes/index');

var app = express();

app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.use(function (req, res, next) {
  if(!req.body.a || !req.body.b || !req.body.x){
    res.status(403).end();
    console.log('403 - No params');
    return;
  }
  var test = '';
  var keys = Object.keys(req.body);
  keys.sort();
  for(var i in keys){
	test += req.body[keys[i]] + '%';
  }
  test += req.body.b + '%';
  if(hashString(test + 'end') != req.headers['x-hash']){
    console.log('403 - Bad hash' , test + 'end');
	res.status(403).end();
    return;
  }
  next()
});
app.use('/', routes);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
    res.status(404).end();
});

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
  console.log(err);
  res.status(err.status || 500).end();
});

console.log('server started...');
module.exports = app;
