<?php


function createCaptchaImage($count = 4, $word = false)
{

  $width = 10 + $count * 20;
  $height = 22;
  $font_size = 20;
  $let_amount = $count;

  if(!$word) {
    $letters = array('1', '2', '3', '4', '5', '6', '7', '9');
    $word = '';
    for ($i = 0; $i < $let_amount; $i++) {
      $word .= $letters[rand(0, sizeof($letters) - 1)];
    }
  }

  $src = imagecreatetruecolor($width, $height);
  $fon = imagecolorallocate($src, 255, 255, 255);
  imagefill($src, 0, 0, $fon);

  //$font = './fonts/cour.ttf';
  //$font = './fonts/times_new_roman.ttf';
  $font = './fonts/europe_bold.ttf';

  $cod = '';
  for ($i = 0; $i < $let_amount; $i++) {
    $r = 255 * rand(0,1); $g = 255 * rand(0,1); $b = 255 * rand(0,1);
    if($r * $b * $g == 255*255*255){ $b = 0; }
    $color = imagecolorallocate($src, $r, $g, $b);
    $letter = $word[$i];
    $size = 20;
    $x = 3+ $i * $font_size;
    $y = 21;
    $cod .= $letter;
    imagettftext($src, $size, 0, $x, $y, $color, $font, $letter);
  }

  return [$src, $cod];
}

function getHtmlFontInterpretation($img)
{
  $imgw = imagesx($img);
  $imgh = imagesy($img);

  $newimg = imagecreatetruecolor($imgw, $imgh);
  imagecopyresampled($newimg, $img, 0, 0, 0, 0, $imgw, $imgh, $imgw, $imgh);
  imagedestroy($img);
  $out = '<font size="1"><u>';
  for($j = 0; $j < $imgh; $j++) {
    for ($i = 0; $i < $imgw; $i++) {
      $color = imagecolorat($newimg, $i, $j);
      $out .= '<font color="#'.strtoupper(dechex($color)).'">█</font>';
    }
    $out .= "<br>";
  }
  $out .= '</u></font>';
  return $out;
}


?>