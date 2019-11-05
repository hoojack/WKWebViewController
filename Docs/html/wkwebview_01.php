<?php
	echo "cookie:\n";
	$cookie = $_COOKIE;
	foreach ($cookie as $key => $value) {
		echo $key . ":" . $value ."\n";
	}
?>