var express = require('express');
var fs = require('fs');
var router = express.Router();

/* GET home page. */
router.post('/', function(req, res, next) {

  var path = __dirname + '/../public/cropped/';
  var result = {images:[]};
  function readFile(filePath, files) {
    fs.readFile(path + filePath, function(err, data){
      if(err){
        res.status(500).end();
        console.log(err);
        return;
      }
      var base64Image = new Buffer(data, 'binary').toString('base64');
      var imageObject = {base64:base64Image, name:filePath};
      if(filePath.match(/secret/)){
        imageObject.onlyCrop = true;
      }
      result.images.push(imageObject);

      if(files.length){
        readFile(files.pop(), files);
      } else {
        res.send(result);
        res.end();
      }
    });
  }

  fs.readdir(path, function (err, files) {
    if(err){
      res.status(500).end();
      console.log(err);
      return;
    }
    readFile(files.pop(), files);
  });
});

router.post('/load', function(req, res, next) {
  if(!req.body.image){
    res.status(413).end();
    return;
  }
  if(req.body.image.match(/secret/) && req.body.b != 'admin'){
    res.status(403).send({'text':'User is not allowed'}).end();
    return;
  }
  var path = __dirname + '/../public/images/' + req.body.image;
  fs.stat(path, function(err, stats) {
    if (err || !stats.isFile()) {
      res.status(404).end();
      return;
    }

    fs.readFile(path, function(err, data){
      var base64Image = new Buffer(data, 'binary').toString('base64');
      res.send({base64:base64Image});
      res.end();
    });
  });
});

module.exports = router;
