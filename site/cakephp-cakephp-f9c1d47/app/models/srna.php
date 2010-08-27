<?php
class Srna extends AppModel {
	var $name = 'Srna';
#	var $validate = array(
#		'name' => array(
#			'notempty' => array(
#				'rule' => array('notempty'),
#				//'message' => 'Your custom message here',
#				//'allowEmpty' => false,
#				//'required' => false,
#				//'last' => false, // Stop validation after this rule
#				//'on' => 'create', // Limit validation to 'create' or 'update' operations
#			),
#		),
#		'start' => array(
#			'numeric' => array(
#				'rule' => array('numeric'),
#				//'message' => 'Your custom message here',
#				//'allowEmpty' => false,
#				//'required' => false,
#				//'last' => false, // Stop validation after this rule
#				//'on' => 'create', // Limit validation to 'create' or 'update' operations
#			),
#		),
#		'stop' => array(
#			'numeric' => array(
#				'rule' => array('numeric'),
#				//'message' => 'Your custom message here',
#				//'allowEmpty' => false,
#				//'required' => false,
#				//'last' => false, // Stop validation after this rule
#				//'on' => 'create', // Limit validation to 'create' or 'update' operations
#			),
#		),
#		'sequence_id' => array(
#			'numeric' => array(
#				'rule' => array('numeric'),
#				//'message' => 'Your custom message here',
#				//'allowEmpty' => false,
#				//'required' => false,
#				//'last' => false, // Stop validation after this rule
#				//'on' => 'create', // Limit validation to 'create' or 'update' operations
#			),
#		),
#		'type_id' => array(
#			'numeric' => array(
#				'rule' => array('numeric'),
#				//'message' => 'Your custom message here',
#				//'allowEmpty' => false,
#				//'required' => false,
#				//'last' => false, // Stop validation after this rule
#				//'on' => 'create', // Limit validation to 'create' or 'update' operations
#			),
#		),
#		'abundance' => array(
#			'numeric' => array(
#				'rule' => array('numeric'),
#				//'message' => 'Your custom message here',
#				//'allowEmpty' => false,
#				//'required' => false,
#				//'last' => false, // Stop validation after this rule
#				//'on' => 'create', // Limit validation to 'create' or 'update' operations
#			),
#		),
#		'experiment_id' => array(
#			'numeric' => array(
#				'rule' => array('numeric'),
#				//'message' => 'Your custom message here',
#				//'allowEmpty' => false,
#				//'required' => false,
#				//'last' => false, // Stop validation after this rule
#				//'on' => 'create', // Limit validation to 'create' or 'update' operations
#			),
#		),
#	);
#	//The Associations below have been created with all possible keys, those that are not needed can be removed

	var $belongsTo = array(
		'Sequence' => array(
			'className' => 'Sequence',
			'foreignKey' => 'sequence_id',
			'conditions' => '',
			'fields' => '',
			'order' => ''
		),
		'Type' => array(
			'className' => 'Type',
			'foreignKey' => 'type_id',
			'conditions' => '',
			'fields' => '',
			'order' => ''
		),
		'Experiment' => array(
			'className' => 'Experiment',
			'foreignKey' => 'experiment_id',
			'conditions' => '',
			'fields' => '',
			'order' => ''
        ),
        'Chromosome' => array(
			'className' => 'Chromosome',
			'foreignKey' => 'chromosome_id',
			'conditions' => '',
			'fields' => '',
			'order' => ''
        )
	);

    var $hasMany = array(
		'Mapping' => array(
			'className' => 'Mapping',
			'foreignKey' => 'srna_id',
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

    function sum_abundancies($annot_id, $exp_id = null) {
        $sql = 'SELECT sum(S.abundance) as abundance_count, sum(S.normalized_abundance) as norm_abundance_count FROM `mappings` M JOIN `srnas` S ON S.id = M.srna_id WHERE M.annotation_id = ' . mysql_real_escape_string($annot_id);
        return $this->query($sql);
    }
}
?>
