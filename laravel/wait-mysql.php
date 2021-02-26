<?php

$mysql_user = $_SERVER["MYSQL_USER"];
$mysql_password = $_SERVER["MYSQL_PASSWORD"];
$database = $_SERVER["MYSQL_DATABASE"];
$host = $_SERVER["LARAVEL_DB_HOST"];

$NUM_OF_ATTEMPTS = 10;
$attempts = 0;

do {
	try {
		$conn = new PDO("mysql:host={$host}; dbname={$database}", $mysql_user, $mysql_password);
		$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		echo "Database Ready";
	} catch(Exception $e) {
		echo "Database not ready";
		$attempts++;
		sleep(2);
        continue;
	}
	break;
} while($attempts < $NUM_OF_ATTEMPTS);

?>