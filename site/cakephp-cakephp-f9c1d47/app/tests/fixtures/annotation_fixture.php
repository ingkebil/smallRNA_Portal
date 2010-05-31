<?php
/* Annotation Fixture generated on: 2010-04-09 15:04:55 : 1270819075 */
class AnnotationFixture extends CakeTestFixture {
	var $name = 'Annotation';

	var $fields = array(
		'id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'primary'),
		'accession_nr' => array('type' => 'string', 'null' => false, 'default' => NULL, 'length' => 45, 'key' => 'index'),
		'model_nr' => array('type' => 'integer', 'null' => false, 'default' => NULL),
		'start' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'index'),
		'stop' => array('type' => 'integer', 'null' => false, 'default' => NULL),
		'chr' => array('type' => 'string', 'null' => false, 'default' => NULL, 'length' => 45),
		'species_id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'index'),
		'seq' => array('type' => 'text', 'null' => false, 'default' => NULL),
		'comment' => array('type' => 'text', 'null' => false, 'default' => NULL),
		'source_id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'index'),
		'indexes' => array('PRIMARY' => array('column' => 'id', 'unique' => 1), 'fk_annotations_sources1' => array('column' => 'source_id', 'unique' => 0), 'start_stop' => array('column' => array('start', 'chr', 'species_id', 'stop'), 'unique' => 0), 'accession_model' => array('column' => array('accession_nr', 'model_nr'), 'unique' => 0), 'fk_annotations_species1' => array('column' => 'species_id', 'unique' => 0)),
		'tableParameters' => array('charset' => 'utf8', 'collate' => 'utf8_general_ci', 'engine' => 'InnoDB')
	);

	var $records = array(
		array(
			'id' => 1,
			'accession_nr' => 'Lorem ipsum dolor sit amet',
			'model_nr' => 1,
			'start' => 1,
			'stop' => 1,
			'chr' => 'Lorem ipsum dolor sit amet',
			'species_id' => 1,
			'seq' => 'Lorem ipsum dolor sit amet, aliquet feugiat. Convallis morbi fringilla gravida, phasellus feugiat dapibus velit nunc, pulvinar eget sollicitudin venenatis cum nullam, vivamus ut a sed, mollitia lectus. Nulla vestibulum massa neque ut et, id hendrerit sit, feugiat in taciti enim proin nibh, tempor dignissim, rhoncus duis vestibulum nunc mattis convallis.',
			'comment' => 'Lorem ipsum dolor sit amet, aliquet feugiat. Convallis morbi fringilla gravida, phasellus feugiat dapibus velit nunc, pulvinar eget sollicitudin venenatis cum nullam, vivamus ut a sed, mollitia lectus. Nulla vestibulum massa neque ut et, id hendrerit sit, feugiat in taciti enim proin nibh, tempor dignissim, rhoncus duis vestibulum nunc mattis convallis.',
			'source_id' => 1
		),
	);
}
?>