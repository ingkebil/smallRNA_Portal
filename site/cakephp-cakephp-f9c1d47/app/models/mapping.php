<?php
class mapping extends AppModel {
	var $name = 'mapping';
	var $validate = array(
		'annotation_id' => array(
			'numeric' => array(
				'rule' => array('numeric'),
				//'message' => 'Your custom message here',
				//'allowEmpty' => false,
				//'required' => false,
				//'last' => false, // Stop validation after this rule
				//'on' => 'create', // Limit validation to 'create' or 'update' operations
			),
		),
		'srna_id' => array(
			'numeric' => array(
				'rule' => array('numeric'),
				//'message' => 'Your custom message here',
				//'allowEmpty' => false,
				//'required' => false,
				//'last' => false, // Stop validation after this rule
				//'on' => 'create', // Limit validation to 'create' or 'update' operations
			),
		),
	);
	//The Associations below have been created with all possible keys, those that are not needed can be removed

	var $belongsTo = array(
		'Annotation' => array(
			'className' => 'Annotation',
			'foreignKey' => 'annotation_id',
			'conditions' => '',
			'fields' => '',
			'order' => ''
		),
		'Srna' => array(
			'className' => 'Srna',
			'foreignKey' => 'srna_id',
			'conditions' => '',
			'fields' => '',
			'order' => 'Srna.type_id, Srna.start'
		)
	);

    var $actsAs = array('Containable');

   # function paginate($conditions, $fields, $order, $limit, $page = 1, $recursive = null, $extra = array()) {
   #     $recursive = 2;
   #     return $this->find('all', compact('conditions', 'fields', 'order', 'limit', 'page', 'recursive', 'group'));
   # }
}
?>
