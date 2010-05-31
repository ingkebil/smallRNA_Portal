<?php
/* Snra Fixture generated on: 2010-04-09 15:04:19 : 1270819459 */
class SnraFixture extends CakeTestFixture {
	var $name = 'Snra';

	var $fields = array(
		'id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'primary'),
		'name' => array('type' => 'string', 'null' => false, 'default' => NULL, 'length' => 45),
		'start' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'index'),
		'stop' => array('type' => 'integer', 'null' => false, 'default' => NULL),
		'sequence_id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'index'),
		'score' => array('type' => 'float', 'null' => false, 'default' => NULL),
		'type_id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'index'),
		'abundance' => array('type' => 'integer', 'null' => false, 'default' => NULL),
		'nomalized_abundance' => array('type' => 'float', 'null' => false, 'default' => NULL),
		'experiment_id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'index'),
		'indexes' => array('PRIMARY' => array('column' => 'id', 'unique' => 1), 'start_stop' => array('column' => array('start', 'stop', 'type_id', 'experiment_id'), 'unique' => 0), 'fk_snras_Sequences1' => array('column' => 'sequence_id', 'unique' => 0), 'fk_snras_experiments1' => array('column' => 'experiment_id', 'unique' => 0), 'fk_snras_types1' => array('column' => 'type_id', 'unique' => 0)),
		'tableParameters' => array('charset' => 'utf8', 'collate' => 'utf8_general_ci', 'engine' => 'InnoDB')
	);

	var $records = array(
		array(
			'id' => 1,
			'name' => 'Lorem ipsum dolor sit amet',
			'start' => 1,
			'stop' => 1,
			'sequence_id' => 1,
			'score' => 1,
			'type_id' => 1,
			'abundance' => 1,
			'nomalized_abundance' => 1,
			'experiment_id' => 1
		),
	);
}
?>