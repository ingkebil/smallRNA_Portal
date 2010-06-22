<?php
class Species extends AppModel {
	var $name = 'Species';
	var $displayField = 'full_name';
    var $actsAs = array('containable');
	var $validate = array(
		'full_name' => array(
			'notempty' => array(
				'rule' => array('notempty'),
				//'message' => 'Your custom message here',
				//'allowEmpty' => false,
				//'required' => false,
				//'last' => false, // Stop validation after this rule
				//'on' => 'create', // Limit validation to 'create' or 'update' operations
			),
		),
		'NCBI_tax_id' => array(
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
			'foreignKey' => 'species_id',
			'dependent' => false,
			'conditions' => '',
			'fields' => '',
			'order' => '',
			'limit' => '',
			'offset' => '',
			'exclusive' => '',
			'finderQuery' => '',
			'counterQuery' => ''
		),
		'Experiment' => array(
			'className' => 'Experiment',
			'foreignKey' => 'species_id',
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


    /**
     * Returns a [species_name]=>[srna_types]=>[experiment_name] structure. 
     * This is very handy for generation of the menu.
     *
     */

    function find_species_types_exps() {
        $exp_type_q = '
            SELECT DISTINCT Species.full_name, Experiment.name, Type.name
            FROM experiments AS Experiment
            JOIN srnas         ON srnas.experiment_id = Experiment.id
            JOIN types AS Type ON Type.id = srnas.type_id
            JOIN species AS Species ON Species.id = Experiment.species_id';
        $exps = $this->Experiment->query($exp_type_q);

        $species = array();
        foreach ($exps as $exp) {
            if (! array_key_exists($exp['Species']['full_name'], $species)) {
                $species[  $exp['Species']['full_name']  ] = array();
            }
            if (! array_key_exists($exp['Type']['name'], $species[ $exp['Species']['full_name'] ])) {
                $species[  $exp['Species']['full_name']  ][  $exp['Type']['name']  ] = array();
            }
            $species[  $exp['Species']['full_name']  ][  $exp['Type']['name']  ][] = $exp['Experiment']['name'];
        }
        return $species;
    }
    
}
?>
