<?php
class Abundancy extends AppModel {

	var $name = 'Abundancy';

#	var $validate = array(
#		'annotation_id' => array(
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
#		'normalized_abundance' => array(
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
#		'count' => array(
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
	//The Associations below have been created with all possible keys, those that are not needed can be removed

	var $belongsTo = array(
		'Annotation' => array(
			'className' => 'Annotation',
			'foreignKey' => 'annotation_id',
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
		)
	);

    /*
     * Only used for the overview in abundancies controller
     */
    function paginate($conditions, $fields, $order, $limit, $page = 1, $recursive = null, $extra = array()) {
        if ($order && is_array($order)) {
            $joy_division = array();
            foreach ($order as $field => $o) {
			    if (strpos($field, '.') !== false) {
                    list($model, $f) = explode('.', $field);
                }
                list(,$exp_id) = explode('_', $field);
                $joy_division["(select normalized_abundance from abundancies where experiment_id = $exp_id and annotation_id = Abundancy.annotation_id)"] = $o;
            }
            $order = $joy_division;
        }

        # paginate
        $parameters = compact('conditions', 'fields', 'order', 'limit', 'page');
        if ($recursive != $this->recursive) {
            $parameters['recursive'] = $recursive;
        }
        return $this->find('all', array_merge($parameters, $extra));
    }

}
?>
