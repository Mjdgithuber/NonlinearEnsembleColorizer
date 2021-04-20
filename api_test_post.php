<?php
// $myObj->name = "Matthew";
// $myObj->age = 21;
// $myObj->city = "Test NY";

// $myJSON = json_encode($myObj);


if ($_SERVER['REQUEST_METHOD'] === 'POST') {
	$file = fopen( '/var/www/html/frame/test.jpg', 'wb' );
	fwrite( $file, base64_decode( $_POST["name"] ) );
	fclose($file);

	echo $_POST["name"];
} else {
	$filename = '/var/www/html/frame/test.jpg';
	$file = fopen($filename, 'r');
	$contents = fread($file, filesize($filename));
	fclose($file);

	echo base64_encode($contents);
}


// $file = fopen( '/var/www/html/frame/test.jpg', 'wb' );
// fwrite( $file, base64_decode( $_POST["name"] ) );
// fclose($file);

// echo $_POST["name"];


// echo exec('whoami');
?>