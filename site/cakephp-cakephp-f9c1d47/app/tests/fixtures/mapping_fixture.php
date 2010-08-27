<?php
/* Mapping Fixture generated on: 2010-08-20 17:08:53 : 1282318553 */
class MappingFixture extends CakeTestFixture {
	var $name = 'Mapping';

	var $fields = array(
		'annotation_id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'primary'),
		'srna_id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'primary'),
		'indexes' => array('PRIMARY' => array('column' => array('annotation_id', 'srna_id'), 'unique' => 1), 'fk_mappings_srnas1' => array('column' => 'srna_id', 'unique' => 0), 'fk_mappings_annotations1' => array('column' => 'annotation_id', 'unique' => 0)),
		'tableParameters' => array('charset' => 'utf8', 'collate' => 'utf8_general_ci', 'engine' => 'InnoDB')
	);

	var $records = array(
		array(
			'annotation_id' => 1,
			'srna_id' => 1
		),
	);
}
?>