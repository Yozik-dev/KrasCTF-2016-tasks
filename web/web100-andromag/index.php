<?php

$mysql_server = 'localhost';
$mysql_db = 'krasctf';
$mysql_user = 'krasctf';
$mysql_passwd = 'kctfF1R5tb100d'; // Это флаг

$db = mysql_connect($mysql_server, $mysql_user, $mysql_passwd) or die('DB return false');
mysql_select_db($mysql_db, $db) or die(mysql_error());
mysql_query("SET NAMES utf8");

$byid = 'ORDER BY id';
$byname = 'ORDER BY name';
$bydesc = 'ORDER BY description';
$byprice = 'ORDER BY price';
$bycreated = 'ORDER BY created_at';
$byupdated = 'ORDER BY updated_at';

$limit3 = 'LIMIT 3';
$limit5 = 'LIMIT 5';
$limit10 = 'LIMIT 10';

$_GET['order'] = isset($_GET['order']) ? $_GET['order'] : 'byid';
$_GET['lim'] = isset($_GET['lim']) ?  intval($_GET['lim']) : 3;
$_GET['page'] = isset($_GET['page']) ? intval($_GET['page']) : 1;
$offset = 'OFFSET ' . ($_GET['page']-1) * $_GET['lim'];

$data = compact($_GET['order'], 'limit' . $_GET['lim'], 'offset');
$query_string = 'SELECT * FROM table_1_1 ' . implode(' ', array_values($data));

$query = mysql_query($query_string) or die("Invalid query: " . mysql_error() . " = $query_string");
$count_query = mysql_query("SELECT COUNT(*) as c FROM table_1_1") or die("Invalid query: " . mysql_error());
$count = (int) mysql_fetch_row($count_query)[0];

function linkCreate($array){
	if(!isset($array['lim'])) $array['lim'] = $_GET['lim'];
	if(!isset($array['page'])) $array['page'] = $_GET['page'];
	if(!isset($array['order'])) $array['order'] = $_GET['order'];
	return array_reduce(array_keys($array), function($c, $k) use ($array){ return $c . '&' . $k . '=' . $array[$k]; }, '');
}

?>

<html>
<head><title>Продукция | Андромаг</title></head>
<body>
<h2>Продукция:</h2>

<p>Показаны: <?=($_GET['page']-1) * $_GET['lim'] + 1?>-<?=$_GET['page'] * $_GET['lim']?></p>

<table border="1" cellspacing="5" cellpadding="5">
	<tr>
		<td><a href="./index.php?<?=linkCreate(['order' => 'byid'])?>">ID</a></td>
		<td><a href="./index.php?<?=linkCreate(['order' => 'byname'])?>">Имя</a></td>
		<td><a href="./index.php?<?=linkCreate(['order' => 'bydesc'])?>">Описание</a></td>
		<td><a href="./index.php?<?=linkCreate(['order' => 'byprice'])?>">Цена</a></td>
		<td><a href="./index.php?<?=linkCreate(['order' => 'bycreated'])?>">Дата создания</a></td>
		<td><a href="./index.php?<?=linkCreate(['order' => 'byupdated'])?>">Дата обновления</a></td>
	</tr>
	<?php if(mysql_num_rows($query)):?>
	<?php while ($row = mysql_fetch_array($query)): ?>
	<tr>
		<td><?= $row['id'] ?></td>
		<td><?= $row['name'] ?></td>
		<td><?= $row['description'] ?></td>
		<td><?= $row['price'] ?></td>
		<td><?= $row['created_at'] ?></td>
		<td><?= $row['updated_at'] ?></td>
	</tr>
	<?php endwhile; ?>
	<?php else: ?>
		<tr><td colspan="6">Нет данных для отображения</td></tr>
	<?php endif; ?>
</table>


<?php for($i = 1; $i < $count / $_GET['lim'] + 1; $i+=1): ?>
	<a href="./index.php?<?=linkCreate(['page' => $i])?>"><?=$i?></a>&nbsp;
<?php endfor; ?>

</body>
</html>