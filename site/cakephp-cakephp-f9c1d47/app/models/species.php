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
     * Returns a 
     *   ['Arabidopsis Thaliana'] => 
     *      ['short_name'] => 'arath',
     *      ['srna_types'] => [srna_types] => [experiment_name]
     * structure. 
     * This is very handy for generation of the menu.
     */

    function find_species_types_exps() {
        $exp_type_q = '
            SELECT DISTINCT Species.full_name, Species.short_name, Experiment.name, Type.name
            FROM experiments AS Experiment
            JOIN srnas         ON srnas.experiment_id = Experiment.id
            JOIN types AS Type ON Type.id = srnas.type_id
            JOIN species AS Species ON Species.id = Experiment.species_id';
        $exps = $this->Experiment->query($exp_type_q);

        $species = array();
        foreach ($exps as $exp) {
            $sp_full_name  = $exp['Species']['full_name'];
            $sp_short_name = $exp['Species']['short_name'];
            $ty_name       = $exp['Type']['name'];
            if (! array_key_exists($sp_full_name, $species)) {
                $species[  $sp_full_name  ] = array('short_name' => array(), 'srna_types' => array());
            }
            $s_f_n =& $species[ $sp_full_name ];
            if (! array_key_exists($sp_short_name, $s_f_n['short_name'])) {
                $s_f_n['short_name'] = $sp_short_name;
            }
            if (! array_key_exists($ty_name, $s_f_n['srna_types'])) {
                $s_f_n['srna_types'][ $ty_name ] = array();
            }
            $s_f_n['srna_types'][ $ty_name ][] = $exp['Experiment']['name'];
        }
        return $species;
    }
    
}
?>
