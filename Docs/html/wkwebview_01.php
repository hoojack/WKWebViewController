<?php
	header("Content-Type:text/html;charset=utf-8");
	echo "cookie:\n";
	$cookie = $_COOKIE;
	foreach ($cookie as $key => $value) {
		echo $key . ":" . $value ."\n";
	}
?>