$('.services .s.on').click(function (event) {
    $('#modal_form').html($('.text-task').html());
    $('#overlay').fadeIn(400, function () {
        $('#modal_form').css('display', 'block')
            .animate({opacity: 1, top: '30%'}, 200);
    });
});

$('#modal_close, #overlay').click(function () {
    $('#modal_form').animate({opacity: 0, top: '45%'}, 200, function () {
        $(this).css('display', 'none');
        $('#overlay').fadeOut(400);
        $('#modal_form').html('').removeClass('no-border');
    });
});

var animateCamera = {opacity: 1, top: '50%', left:'50%', 'margin-left':'-512px', 'margin-top':'-300px'};
$('.camera.today').click(function (event) {
    $('#modal_form').html(videoToday).addClass('no-border');
    $('#overlay').fadeIn(400, function () {
        $('#modal_form').css('display', 'block')
            .animate(animateCamera, 200);
    });
});

$('.camera.left').click(function (event) {
    $('#modal_form').html(videoLeft).addClass('no-border');
    $('#overlay').fadeIn(400, function () {
        $('#modal_form').css('display', 'block')
            .animate(animateCamera, 200);
    });
});

$('.camera.right').click(function (event) {
    $('#modal_form').html(videoRight).addClass('no-border');
    $('#overlay').fadeIn(400, function () {
        $('#modal_form').css('display', 'block')
            .animate(animateCamera, 200);
    });
});

$('.camera.center').click(function (event) {
    $('#modal_form').html(videoCenter).addClass('no-border');
    $('#overlay').fadeIn(400, function () {
        $('#modal_form').css('display', 'block')
            .animate(animateCamera, 200);
    });
});