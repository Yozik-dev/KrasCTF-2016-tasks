<?php

ini_set('display_errors', 1);
error_reporting(E_ALL);

const REPEAT_TO_GET_FLAG = 6;
const TIMEOUT_TO_GET_FLAG = 10;

session_start();
include "captcha.php";
list($img, $code) = createCaptchaImage(rand(3, 7));

if (isset($_SESSION['solved']) && $_SESSION['timeout'] > time()) {
  if (isset($_POST['code']) && $_SESSION['code'] == $_POST['code']) {
    $_SESSION['solved']++;
    if($_SESSION['solved'] == REPEAT_TO_GET_FLAG){
      list($img, $code) = createCaptchaImage(10, '#kras7a841');
    }
  } else {
    $_SESSION['solved'] = 0;
  } 
} else {
  $_SESSION['timeout'] = time() + TIMEOUT_TO_GET_FLAG;
  $_SESSION['solved'] = 0;
}
$_SESSION['code'] = $code;

?>
<html>
<head>
  <meta charset="utf-8">
</head>
<body>
<hr>
<?= getHtmlFontInterpretation($img); ?>
<hr>
<p>Success:<?= $_SESSION['solved'] ?></p>
<p>Timeout:<?= $_SESSION['timeout'] - time() ?></p>
<form action="./index.php" method="post">
  CODE:<input type="text" name="code">
  <input type="submit">
</form>
</body>
</html>
