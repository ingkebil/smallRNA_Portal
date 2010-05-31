<?php
/* Structure Fixture generated on: 2010-04-09 15:04:17 : 1270820237 */
class StructureFixture extends CakeTestFixture {
	var $name = 'Structure';

	var $fields = array(
		'id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'primary'),
		'annotation_id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'index'),
		'start' => array('type' => 'integer', 'null' => false, 'default' => NULL),
		'stop' => array('type' => 'integer', 'null' => false, 'default' => NULL),
		'indexes' => array('PRIMARY' => array('column' => 'id', 'unique' => 1), 'fk_structures_annotations1' => array('column' => 'annotation_id', 'unique' => 0)),
		'tableParameters' => array('charset' => 'utf8', 'collate' => 'utf8_general_ci', 'engine' => 'InnoDB')
	);

	var $records = array(
		array(
			'id' => 1,
			'annotation_id' => 1,
			'start' => 1,
			'stop' => 1
		),
	);
}
?>