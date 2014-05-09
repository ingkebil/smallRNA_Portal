<?php
/* Sequence Fixture generated on: 2010-06-22 11:06:24 : 1277197644 */
class SequenceFixture extends CakeTestFixture {
	var $name = 'Sequence';

	var $fields = array(
		'id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'primary'),
		'seq' => array('type' => 'string', 'null' => false, 'default' => NULL, 'length' => 45, 'key' => 'unique'),
		'indexes' => array('PRIMARY' => array('column' => 'id', 'unique' => 1), 'seq' => array('column' => 'seq', 'unique' => 1)),
		'tableParameters' => array('charset' => 'utf8', 'collate' => 'utf8_general_ci', 'engine' => 'InnoDB')
	);

	var $records = array(
		array(
			'id' => 1,
			'seq' => 'Lorem ipsum dolor sit amet'
		),
	);
}
?>