<?php
/* Species Fixture generated on: 2010-06-22 11:06:36 : 1277197656 */
class SpeciesFixture extends CakeTestFixture {
	var $name = 'Species';

	var $fields = array(
		'id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'primary'),
		'full_name' => array('type' => 'string', 'null' => false, 'default' => NULL, 'length' => 45),
		'NCBI_tax_id' => array('type' => 'integer', 'null' => false, 'default' => NULL),
		'indexes' => array('PRIMARY' => array('column' => 'id', 'unique' => 1)),
		'tableParameters' => array('charset' => 'utf8', 'collate' => 'utf8_general_ci', 'engine' => 'InnoDB')
	);

	var $records = array(
		array(
			'id' => 1,
			'full_name' => 'Lorem ipsum dolor sit amet',
			'NCBI_tax_id' => 1
		),
	);
}
?>