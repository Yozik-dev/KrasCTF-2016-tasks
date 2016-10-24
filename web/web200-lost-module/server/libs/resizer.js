var Jimp = require("jimp");
var fs = require('fs');

var path = '../public/images/';
var imagesPath = fs.readdirSync(path);

function resizeImg(path, imgName){
    Jimp.read(path + imgName, function (err, image) {
        if (err) throw err;
        image.resize(Jimp.AUTO, 100)            // resize
            .write(path + '/../cropped/' + imgName);
        console.log(imgName + ' done');
        if(imagesPath.length){
            resizeImg(path,imagesPath.pop());
        }
    });
}

resizeImg(path, imagesPath.pop());