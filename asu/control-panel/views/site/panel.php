<?php
/* @var $this yii\web\View */
/* @var $stage integer */

$this->title = 'Star control panel';
$this->registerCssFile('/vendor/bootstrap/css/bootstrap.min.css');
$this->registerCssFile('/cabinet/common.css');

$this->registerJsFile('/vendor/jquery/jquery-3.1.0.min.js', ['position' => \yii\web\View::POS_HEAD]);
$this->registerJsFile('/vendor/flot/jquery.flot.js', ['position' => \yii\web\View::POS_HEAD]);
$this->registerJsFile('/cabinet/common.js', ['position' => \yii\web\View::POS_END]);

$stageDir = sha1('x' . $stage . 'o' . $stage . 'solb');
$this->registerCssFile('/cabinet/' . $stageDir  . '/' . $stage . '.css');
$this->registerJsFile('/cabinet/' . $stageDir  . '/' . $stage . '.js', ['position' => \yii\web\View::POS_END]);

?>
<!-- FLAG FOR LOG IN COSMOPANEL: #lol111864, THAT'S NOT ALL, PUSH THE BUTTON -->
<?= $this->render('_stages/' . $stage); ?>
