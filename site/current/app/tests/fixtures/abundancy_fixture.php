<?php
/* Abundancy Fixture generated on: 2010-11-01 17:11:02 : 1288629122 */
class AbundancyFixture extends CakeTestFixture {
	var $name = 'Abundancy';

	var $fields = array(
		'annotation_id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'length' => 10, 'key' => 'primary'),
		'experiment_id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'length' => 10, 'key' => 'primary'),
		'normalized_abundance' => array('type' => 'integer', 'null' => false, 'default' => NULL),
		'abundance' => array('type' => 'integer', 'null' => false, 'default' => NULL),
		'count' => array('type' => 'integer', 'null' => false, 'default' => NULL),
		'indexes' => array('PRIMARY' => array('column' => array('annotation_id', 'experiment_id'), 'unique' => 1)),
		'tableParameters' => array('charset' => 'utf8', 'collate' => 'utf8_general_ci', 'engine' => 'MyISAM')
	);

	var $records = array(
		array(
			'annotation_id' => 1,
			'experiment_id' => 1,
			'normalized_abundance' => 1,
			'abundance' => 1,
			'count' => 1
		),
	);
}
?>