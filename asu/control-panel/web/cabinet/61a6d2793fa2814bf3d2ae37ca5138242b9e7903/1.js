var videoToday = '<iframe width="1024" height="576" src="https://www.youtube.com/embed/cLM1rnxqTjg?autoplay=1&showinfo=0&controls=0&loop=1&playlist=cLM1rnxqTjg" frameborder="0" allowfullscreen></iframe>';
var videoLeft = '';
var videoRight = '';
var videoCenter = '';

$(function () {

    // We use an inline data source in the example, usually data would
    // be fetched from a server

    var data = [],
        totalPoints = 300;

    function getRandomData() {

        if (data.length > 0)
            data = data.slice(1);

        while (data.length < totalPoints) {
            var prev = data.length > 0 ? data[data.length - 1] : 50,
                y = prev + Math.random() * 10 - 5;

            if (y < 5) {
                y = 5;
            } else if (y > 95) {
                y = 95;
            }
            data.push(y);
        }

        var res = [];
        for (var i = 0; i < data.length; ++i) {
            res.push([i, data[i]])
        }

        return {data:res, color:'rgb(26, 255, 179)'};
    }

    var plot = $.plot("#wave-placeholder", [getRandomData()], {
        series: { shadowSize: 0 },
        yaxis: {
            show: false,
            min: 0,
            max: 100
        },
        xaxis: { show: false },
        grid: {
            borderWidth: {
                top: 0,
                right: 2,
                bottom: 0,
                left: 2
            },
            color: 'rgb(26, 255, 179)'
        }
    });

    var updateInterval = 100;
    function update() {
        plot.setData([getRandomData()]);
        plot.draw();
        setTimeout(update, updateInterval);
    }
    update();

});

$(document).ready(function(){
    var $block, onAutoGame = true, size = 6;
    for(var i = 0; i < size * size; i++) {
        $block = $('<div>')
            .addClass('light')
            .attr('data-x', i % size)
            .attr('data-y', Math.floor(i / size));
        if(Math.random() > 0.5){
            $block.addClass('on')
        }
        $block.appendTo('.lights-out');
    }

    $('.light').click(function(event, interval){
        var $this = $(this), x = $this.data('x'), y = $this.data('y');
        $this.toggleClass('on');
        $('.light[data-x="' + (x-1) + '"][data-y="' + (y-1) + '"]').toggleClass('on');
        $('.light[data-x="' + (x-1) + '"][data-y="' + (y+1) + '"]').toggleClass('on');
        $('.light[data-x="' + (x+1) + '"][data-y="' + (y+1) + '"]').toggleClass('on');
        $('.light[data-x="' + (x+1) + '"][data-y="' + (y-1) + '"]').toggleClass('on');
        if(interval == undefined) {
            clearInterval(timer);
            if(win()){
                $('.light').addClass('done');
            }
        }
    });

    function win() {
        var a = 0;
        $('.light').each(function() {
            if($(this).hasClass('on')){
                a = 1;
            }
        });
        return !a;
    }


    var timer = setInterval(function(){
        var x = Math.floor(Math.random() * size),
            y = Math.floor(Math.random() * size);
        $('.light[data-x="' + x + '"][data-y="' + y + '"]').trigger('click', true);
    }, 500);
});