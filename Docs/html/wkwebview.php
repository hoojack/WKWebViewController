<!DOCTYPE html>
<html>
<head>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
	<title>PHP Page</title>
	<style type="text/css">
		body { font-size: 15px }
	</style>
</head>
<body>
	<h1>PHP Page</h1>
<?
	echo "cookie:";
	$cookie = $_COOKIE;
	foreach ($cookie as $key => $value) {
		echo $key . ":" . $value ."-";
	}
?>
</body>
</html>
