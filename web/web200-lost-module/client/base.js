chrome.runtime.onMessage.addListener(function (request, sender, sendResponse){
    if(request.to !== undefined && request.to == 'page'){
        console.log('get message:', request);
        switch (request.action){
            case 's-b':
                if(!localStorage.getItem('b')){
                    //localStorage.setItem('login', request.value);
                    localStorage.setItem('b', request.value);
                }
                sendResponse({status:true});
                break;
            default:
                sendResponse({action:'default', status: false, content:'empty'});
                break;
        }
        return true;
    }
    return false;
});

var URL_HOST = 'http://127.0.0.1:3000/';
function loadConnection() {
    $.ajax({
        url: URL_HOST,
        method: 'POST',
        data: {a:Math.random(), b:localStorage.getItem('b'), x:Math.random()},
        beforeSend: function () {
            $('#ws-notice').html('Установка соединения').removeClass('bg-danger');
        },
        success: function (data) {
            if(data && data.images){
                for(var i in data.images){
                    var image = data.images[i];
                    var block = $('<div>').addClass('col-md-3');
                    var img = $('<img>').attr('src', 'data:image/jpg;base64,' + image.base64)
                        .attr('data-url', image.name);
                    if(image.onlyCrop){
                        img.addClass('blocked');
                    } else {
                        img.addClass('modal-open');
                    }
                    block.append(img);
                    $('#images-block').append(block);
                }
                $('#ws-notice').html('Соединение установлено').removeClass('bg-warning');
                $('#ws-proxy-count').html(data.images.length);
                loadLinkImages();
            }
        }
    });
}

setTimeout(loadConnection, 2000);


function loadLinkImages(){
    $('.modal-open').click( function(event){
        event.preventDefault();
        $('#modal-body').html('');
        $('#overlay').fadeIn(400, function(){
            $('#modal_form').css('display', 'block')
                .animate({opacity: 1, top: '30%'}, 200);
        });
        var $self = $(this);
        $.ajax({
            url: URL_HOST + 'load',
            method: 'POST',
            data: {a:Math.random(), b:localStorage.getItem('b'), image: $self.attr('data-url'), x:Math.random()},
            beforeSend: function () {

            },
            success: function (data) {
                if(data && data.base64){
                    var img = $('<img>').attr('src', 'data:image/jpg;base64,' + data.base64);
                    $('#modal-body').append(img);
                }
            }
        });
    });

    $('#modal_close, #overlay').click( function(){
        $('#modal_form').animate({opacity: 0, top: '45%'}, 200, function(){
            $(this).css('display', 'none');
            $('#overlay').fadeOut(400);
        });
    });
}