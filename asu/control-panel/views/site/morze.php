<?php
/* @var $this yii\web\View */

$this->title = 'Star control panel';
$this->registerCssFile('/Zfls538dgds2/jsue63hd.css');
$this->registerJsFile('/Zfls538dgds2/jquery-3.1.0.slim.min.js', ['position' => \yii\web\View::POS_HEAD]);

?>

<form method="post">
    <input type="hidden" name="<?= Yii::$app->request->csrfParam; ?>" value="<?= Yii::$app->request->csrfToken; ?>" />
    <div class="line-block">
        <div class="help">Login:</div>
        <div class="input-block"><input type="text" name="LoginForm[username]"></div>
    </div>
    <div class="line-block">
        <div class="help">Password:</div>
        <div class="input-block"><input type="text" name="LoginForm[password]"></div>
    </div>
    <div class="line-block">
        <input type="submit" value="Log In">
    </div>
</form>

<script>
    $(document).ready(function(){
        var $block,
            heightW = $(window).height() - 100,
            widthW = $(window).width() - 100,
            top, left;
        for(var i = 0; i < 40; i++) {
            top = Math.random() * 10000 % heightW;
            left = Math.random() * 10000 % widthW;
            if(top < 80 && left < 330){
                i--;
                continue;
            }
            $block = $('<div>')
                .offset({top: top, left: left})
                .addClass('star')
                .appendTo('body');
        }
    });
</script>
