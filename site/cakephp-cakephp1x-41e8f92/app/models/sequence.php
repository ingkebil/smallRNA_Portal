<?php
class Sequence extends AppModel {
	var $name = 'Sequence';
	//The Associations below have been created with all possible keys, those that are not needed can be removed

	var $hasMany = array(
		'Snra' => array(
			'className' => 'Snra',
			'foreignKey' => 'sequence_id',
			'dependent' => false,
			'conditions' => '',
			'fields' => '',
			'order' => '',
			'limit' => '',
			'offset' => '',
			'exclusive' => '',
			'finderQuery' => '',
			'counterQuery' => ''
		)
	);

}
?>