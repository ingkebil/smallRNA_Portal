<?php
class Type extends AppModel {
	var $name = 'Type';
	//The Associations below have been created with all possible keys, those that are not needed can be removed

	var $hasMany = array(
		'Snra' => array(
			'className' => 'Snra',
			'foreignKey' => 'type_id',
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