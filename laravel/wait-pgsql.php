<?php

$pgsql_user = $_SERVER["PGSQL_USER"];
$pgsql_password = $_SERVER["PGSQL_PASSWORD"];
$database = $_SERVER["PGSQL_DB"];
$host = $_SERVER["LARAVEL_DB_HOST"];

$NUM_OF_ATTEMPTS = 10;
$attempts = 0;

do {
	try {
		$conn = new PDO("pgsql:host={$host}; dbname={$database}", $pgsql_user, $pgsql_password);
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