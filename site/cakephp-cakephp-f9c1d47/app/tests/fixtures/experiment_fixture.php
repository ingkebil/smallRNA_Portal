<?php
/* Experiment Fixture generated on: 2010-06-22 11:06:52 : 1277197612 */
class ExperimentFixture extends CakeTestFixture {
	var $name = 'Experiment';

	var $fields = array(
		'id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'primary'),
		'name' => array('type' => 'string', 'null' => false, 'default' => NULL, 'length' => 45),
		'description' => array('type' => 'text', 'null' => true, 'default' => NULL),
		'species_id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'index'),
		'internal' => array('type' => 'integer', 'null' => true, 'default' => '0', 'length' => 6),
		'indexes' => array('PRIMARY' => array('column' => 'id', 'unique' => 1), 'fk_experiments_species1' => array('column' => 'species_id', 'unique' => 0)),
		'tableParameters' => array('charset' => 'utf8', 'collate' => 'utf8_general_ci', 'engine' => 'InnoDB')
	);

	var $records = array(
		array(
			'id' => 1,
			'name' => 'Lorem ipsum dolor sit amet',
			'description' => 'Lorem ipsum dolor sit amet, aliquet feugiat. Convallis morbi fringilla gravida, phasellus feugiat dapibus velit nunc, pulvinar eget sollicitudin venenatis cum nullam, vivamus ut a sed, mollitia lectus. Nulla vestibulum massa neque ut et, id hendrerit sit, feugiat in taciti enim proin nibh, tempor dignissim, rhoncus duis vestibulum nunc mattis convallis.',
			'species_id' => 1,
			'internal' => 1
		),
	);
}
?>