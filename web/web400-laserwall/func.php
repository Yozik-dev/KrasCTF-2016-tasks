<?php

include "db.php";
const SHSESSID = 'SHSESSID';

function getRandom($lenght = 32) {
	$dist = 'qwertyuiopasdfghjklzxcvbnm1234567890-_QWERTYUIOPASDFGHJKLZXCVBNM';
	$result = '';
	for($i = 0; $i < $lenght; $i++){
		$char = $dist[rand(0, strlen($dist)-1)];
		$result .= $char;
	}
	return $result;
} 

function getSession(){
    global $pdo;
	if(isset($_COOKIE[SHSESSID])){
        return $_COOKIE[SHSESSID];
    } else {
        $sessid = getRandom(48);
        setcookie(SHSESSID, $sessid, time()+60*60*2);
        $pdo->exec("INSERT INTO shadowd_sess (sess) VALUES ('$sessid')");
        return $sessid;
    }
}

function getCountTesters(){
	global $pdo;
	$stmt = $pdo->prepare("SELECT COUNT(*) as ccc FROM shadowd_sess");
    $stmt->execute();
	$result = 0;
    while ($row = $stmt->fetch(PDO::FETCH_LAZY)){
        $result = $row->ccc;
    }
	return $result;
}

function saveUA($sessid){
    global $pdo;
    $ua = isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : '';
    $sql = "INSERT INTO shadowd_ua (session_id, ua) VALUES ((SELECT id FROM shadowd_sess WHERE sess='$sessid' LIMIT 1), '$ua')";
    try {
        $pdo->exec($sql);
    } catch (\Exception $e) {
        echo $sql . '<br><br>' . $e->getMessage();
        exit;
    }
}

function getLastUA($sessid) {
    global $pdo;
    $result = [];
    $stmt = $pdo->prepare("SELECT ua FROM shadowd_ua WHERE session_id = (SELECT id FROM shadowd_sess WHERE sess='$sessid' LIMIT 1)");
    $stmt->execute();
    while ($row = $stmt->fetch(PDO::FETCH_LAZY)){
        $result[] = $row->ua;
    }
    return $result;
}

$SID = getSession();
$countTesters = getCountTesters();
saveUA($SID);
$lastUA = getLastUA($SID);