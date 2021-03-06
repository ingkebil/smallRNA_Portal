<?php
class Sequence extends AppModel {
	var $name = 'Sequence';
#	var $validate = array(
#		'seq' => array(
#			'notempty' => array(
#				'rule' => array('notempty'),
#				//'message' => 'Your custom message here',
#				//'allowEmpty' => false,
#				//'required' => false,
#				//'last' => false, // Stop validation after this rule
#				//'on' => 'create', // Limit validation to 'create' or 'update' operations
#			),
#		),
#	);
	//The Associations below have been created with all possible keys, those that are not needed can be removed

	var $hasMany = array(
		'Srna' => array(
			'className' => 'Srna',
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

    var $actsAs = array('containable');

}
?>
