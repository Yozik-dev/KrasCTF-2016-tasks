$(function () {
    $('#message-form').on('submit', function () {
        var $self = $(this);
        $.ajax({
            url: $self.attr('action'),
            method: 'POST',
            data: $self.serialize(),
            dataType: 'JSON',
            success: function (data) {
                if (!data || !data['status']) {
                    alert('fail operation');
                    return;
                }
                $('#message-input').val('');
            },
            error: function (jqXHR, textStatus) {
                alert('Some problems, page will be reloaded');
                window.location.href = '/';
            }
        });
        return false;
    });

    var lastUpdatedTime;
    $.ajax({
        url: '/time',
        method: 'GET',
        dataType: 'JSON',
        success: function (data) {
            if (!data || !data['time']) {
                return;
            }
            lastUpdatedTime = new Date(data['time']);
            LongPool();
        },
        error: function (jqXHR, textStatus) {
            console.log('fail');
        }
    });

    function LongPool(){
        $.ajax({
            url: '/listen',
            method: 'GET',
            data: {date:lastUpdatedTime},
            dataType: 'JSON',
            success: function (data) {
                if (!data || !data['status']) {
                    return;
                }
                var messages = data['messages'];
                for(var i in messages) {
                    var messageTime = new Date(messages[i].created_at);
                    if(lastUpdatedTime < messageTime){
                        lastUpdatedTime = messageTime;
                    }
                    var block = $('<div>').html(messages[i].user_from + ': ' + messages[i].message + ' @' + messageTime.toLocaleString());
                    $('.messages').prepend(block);
                }
                LongPool();

            },
            error: function (jqXHR, textStatus) {
                //alert('Some problems, page will be reloaded');
                //window.location.href = '/';
                console.log('fail');
            }
        });
    }
});