<?php
/* Sequence Fixture generated on: 2010-04-09 15:04:03 : 1270819443 */
class SequenceFixture extends CakeTestFixture {
	var $name = 'Sequence';

	var $fields = array(
		'id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'primary'),
		'seq' => array('type' => 'string', 'null' => true, 'default' => NULL, 'length' => 45),
		'seq_hash' => array('type' => 'integer', 'null' => true, 'default' => NULL, 'key' => 'index'),
		'indexes' => array('PRIMARY' => array('column' => 'id', 'unique' => 1), 'seq_hash' => array('column' => 'seq_hash', 'unique' => 0)),
		'tableParameters' => array('charset' => 'utf8', 'collate' => 'utf8_general_ci', 'engine' => 'InnoDB')
	);

	var $records = array(
		array(
			'id' => 1,
			'seq' => 'Lorem ipsum dolor sit amet',
			'seq_hash' => 1
		),
	);
}
?>