<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

putenv('SHADOWD_CONNECTOR_CONFIG=' . __DIR__ . '/connectors.ini');
require(__DIR__ . '/shadowd_php-master/src/Connector.php');

$connectorStatus = \shadowd\Connector::start();
$attackStatus = isset($connectorStatus['attack']) ? $connectorStatus['attack'] : true;

include "func.php";

?>

<html>
<head>
<meta charset="UTF-8">
<title>WAF</title>
</head>
<body style="background: <?= $attackStatus ? '#ff1800' : '#99FF66';?>">

Hello strangers! U wanna attack? Do it
<form method="POST" action="index.php">
<input type="text" name="param">
<input type="submit">
</form>
Count testers on site with u:<?=$countTesters?>
<br>
<table>
	<tr>
		<th>#</th>
		<th>User-Agent</th>
	</tr>
	<?php $i = 0; ?>
	<?php foreach($lastUA as $ua): ?>
	<tr>
		<td><?=++$i?></td>
		<td><?=$ua?></td>
	</tr>
	<?php endforeach; ?>
</table>

</body>
</html>
