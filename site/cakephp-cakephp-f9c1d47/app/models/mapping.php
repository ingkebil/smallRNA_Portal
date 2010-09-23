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

    /**
     * Finds in one query the same as find('all', array('conditions' => $conds)); but it returns array('srna_id');
     * This way we don't have to transform a gigantic array that the original would return to the array we really want.
     */
    function findSrnaIds($cond) {
        $q = 'SELECT `Mapping`.`srna_id` FROM `mappings` AS `Mapping` LEFT JOIN `annotations` AS `Annotation` ON (`Mapping`.`annotation_id` = `Annotation`.`id`) WHERE ';
        $c = array();
        foreach ($cond as $key => $value) {
            $c[] = $key . " '" . mysql_real_escape_string($value) . "'";
        }
        $q .= implode(' AND ', $c);

        return $this->query($q);
    }
}
?>
