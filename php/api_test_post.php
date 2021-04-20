<?php
// $myObj->name = "Matthew";
// $myObj->age = 21;
// $myObj->city = "Test NY";

// $myJSON = json_encode($myObj);





$file = fopen( '/var/www/html/frame/test.jpg', 'wb' );
fwrite( $file, base64_decode( $_POST["name"] ) );
fclose($file);

echo $_POST["name"];


// echo exec('whoami');
?>