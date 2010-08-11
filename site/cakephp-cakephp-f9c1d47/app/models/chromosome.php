<?php
class Chromosome extends AppModel {
	var $name = 'Chromosome';
	var $validate = array(
		'name' => array(
			'notempty' => array(
				'rule' => array('notempty'),
				//'message' => 'Your custom message here',
				//'allowEmpty' => false,
				//'required' => false,
				//'last' => false, // Stop validation after this rule
				//'on' => 'create', // Limit validation to 'create' or 'update' operations
			),
		),
		'length' => array(
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

	var $hasMany = array(
		'Annotation' => array(
			'className' => 'Annotation',
			'foreignKey' => 'chromosome_id',
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

    var $belongsTo = array(
        'Species' => array(
			'classname' => 'species',
			'foreignkey' => 'species_id',
			'conditions' => '',
			'fields' => '',
			'order' => ''
        )
    );

    var $actsAs = array('containable');

    function get_chr_annoj($species_id) {
        $chrs = $this->find('list', array('conditions' => array('species_id' => $species_id), 'fields' => array('Chromosome.name', 'Chromosome.length'), 'contain' => false));

        $result = array();
        foreach ($chrs as $name => $size) {
            $result[] = array('id' => $name, 'size' => $size);
        }
        return $result;
    }

}
?>
