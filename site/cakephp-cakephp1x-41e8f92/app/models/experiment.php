<?php
class Experiment extends AppModel {
	var $name = 'Experiment';
	//The Associations below have been created with all possible keys, those that are not needed can be removed

	var $belongsTo = array(
		'Species' => array(
			'className' => 'Species',
			'foreignKey' => 'species_id',
			'conditions' => '',
			'fields' => '',
			'order' => ''
		)
	);

	var $hasMany = array(
		'Snra' => array(
			'className' => 'Snra',
			'foreignKey' => 'experiment_id',
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