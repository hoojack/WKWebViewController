<?php
	header("Content-type:text/html");
	
	echo "PHP Page cookie:\n";
	$cookie = $_COOKIE;
	foreach ($cookie as $key => $value) {
		echo $key . ":" . $value ."\n";
	}
?>