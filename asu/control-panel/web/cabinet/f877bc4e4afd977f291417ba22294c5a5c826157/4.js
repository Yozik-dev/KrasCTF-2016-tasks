var videoToday = '<iframe width="1024" height="576" src="https://www.youtube.com/embed/OHVZl405eyU?autoplay=1&showinfo=0&controls=0&loop=1&playlist=OHVZl405eyU" frameborder="0" allowfullscreen></iframe>';
var videoLeft = '<iframe width="1024" height="576" src="https://www.youtube.com/embed/Vb3MxGOqxsk?autoplay=1&showinfo=0&controls=0" frameborder="0" allowfullscreen></iframe>';
var videoRight = '<iframe width="1024" height="576" src="https://www.youtube.com/embed/IlF2q3pLPHQ?autoplay=1&showinfo=0&controls=0" frameborder="0" allowfullscreen></iframe>';
var videoCenter = '<iframe width="1024" height="576" src="https://www.youtube.com/embed/zCkM4ms5OdU?autoplay=1&showinfo=0&controls=0" frameborder="0" allowfullscreen></iframe>';

$(function () {

    // We use an inline data source in the example, usually data would
    // be fetched from a server

    var data = [],
        totalPoints = 50;

    function getRandomData() {

        if (data.length > 0)
            data = data.slice(1);

        while (data.length < totalPoints) {
            var y = 50 + (Math.random() > 0.5 ? -1 : 1) * Math.random() * 3;

            data.push(y);
        }

        var res = [];
        for (var i = 0; i < data.length; ++i) {
            res.push([i, data[i]])
        }

        return {data:res, color:'rgb(255, 92, 51)'};
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
            color: 'rgb(255, 92, 51)'
        }
    });

    var updateInterval = 500;
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
        $block.appendTo('.lights-out');
    }

    $('.light').click(function(event, interval){
        var $this = $(this), x = $this.data('x'), y = $this.data('y');
        $this.toggleClass('done');
        $('.light[data-x="' + (x-1) + '"][data-y="' + (y-1) + '"]').toggleClass('done');
        $('.light[data-x="' + (x-1) + '"][data-y="' + (y+1) + '"]').toggleClass('done');
        $('.light[data-x="' + (x+1) + '"][data-y="' + (y+1) + '"]').toggleClass('done');
        $('.light[data-x="' + (x+1) + '"][data-y="' + (y-1) + '"]').toggleClass('done');
    });
});