<?php
class DATABASE_CONFIG {

	var $default = array(
		'driver' => 'mysql',
		'persistent' => false,
		'host' => 'localhost',
		'login' => 'kebil',
        'password' => '',
		'database' => 'smallrna_arath',
		'encoding' => 'UTF-8'
	);

	var $test = array(
		'driver' => 'mysql',
		'persistent' => false,
		'host' => 'localhost',
		'login' => 'kebil',
		'password' => 'kebil',
		'database' => 'smallrna_test',
		'encoding' => 'UTF-8'
	);
}
?>
