<?php
class SrnasController extends AppController {

	var $name = 'Srnas';
    var $components = array('RequestHandler');
    var $helpers = array('Ajax', 'Jquery');
    var $uses = array('Srna', 'Type', 'Chromosome', 'Experiment');

	function index() {
        $this->paginate = array('Srna' => array('unbindcount' => 1));
		$this->set('srnas', $this->paginate());
	}

    function show(/*$species, $type, $exp*/) {
    }

    function experiment($id) {
        $this->paginate = array('Srna' => array('unbindcount' => 1));
        $this->set('srnas', $this->paginate($this->Srna, array('Experiment_id' => $id)));
    }

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid srna', true));
			$this->redirect(array('action' => 'index'));
		}
        $srna = $this->Srna->read(null, $id);
        $this->paginate = array('Annotation' => array('recursive' => 0));
        $annotations = $this->paginate($this->Srna->Experiment->Species->Annotation, array('Annotation.start <=' => $srna['Srna']['start'], 'Annotation.stop >=' => $srna['Srna']['stop'], 'chromosome_id' => $srna['Srna']['chromosome_id']));
        $this->set('annotations', $annotations);
		$this->set('srna', $srna);
	}

    function between($start = 0, $stop = 0, $chr_id = null) {
        if ($this->RequestHandler->isAjax()) {
            $this->layout = 'ajax';
        }
        $this->paginate = array('Mapping' => array('contain' => array('Srna.Chromosome', 'Srna.Type', 'Srna.Experiment')));
        $conds = array('Srna.start >=' => $start, 'Srna.stop <=' => $stop);
        if (!is_null($chr_id)) {
            $conds['Srna.chromosome_id'] = $chr_id;
        }
        $srnas = $this->paginate($this->Srna->Mapping, $conds);
        if (isset($this->params['requested'])){
            return $srnas;
        }
        $this->set('srnas', $srnas);
    }

    function search() {
        $this->cacheAction = false;
        if (! empty($this->data)) {
            #     [Srna] => Array
            #          (
            #              [chromosome_id] => 
            #              [strand] => 
            #              [type_id] => 
            #              [experiment_id] => 
            #              [start] => 
            #              [stop] => 
            #              [normalized_abundance_between] => 
            #              [normalized_abundance_stop] => 
            #              [sequence_contains] => aaagt
            #          )

            if (!$this->Srna->validates($this->data)) {
                print 'FALSE';
            }


            foreach ($this->data as $key => $values) {
                $conditions[ $key ] = array_filter($values, create_function('$a', 'return ! empty($a) || $a == 0;'));
                if (empty($conditions[ $key ])) {
                    unset($conditions[ $key ]);
                }
            }
            $named = array();
            foreach ($conditions as $model => $keys) {
                $url_model = urlencode($model);
                foreach ($keys as $key => $value) {
                    $url_key   = urlencode($key);
                    $url_value = urlencode($value);
                    $named[ "$url_model.$url_key" ] = $url_value;
                }
            }
            $named['action'] = 'results';

            $this->redirect($named);
        }
		$types = $this->Srna->Type->find('list');
		$experiments = $this->Srna->Experiment->find('list');
        $chromosomes = $this->Srna->Chromosome->find('list', array('order' => array('name' => 'ASC')));
		$this->set(compact('types', 'experiments', 'chromosomes'));
    }

    function results() {
        $options = $this->_setOptions();
        $this->paginate = array('Srna' => $options);
        $srnas = $this->paginate($this->Srna);
        $this->set('srnas', $srnas);
    }

    function stats($model) {
        $options = $this->_setOptions();

        $model = strtolower($model);
        $Model = ucfirst($model);

        switch ($model) {
        case 'experiment':
        case 'chromosome':
        case 'type':
            # the 'normal' way of doing things takes up to 3 minutes
            #$options['contain'] = array($Model);
            #$options['fields'] = array('COUNT(*) AS cnt', "$Model.id", "$Model.name");
            #$options['group']  = array('Srna.'.$model.'_id');
            #$options['order']  = 'null'; # avoid the unnecessary filesort
            #$stats = $this->Srna->find('all', $options);

            # the 'complex optimized' way avoiding the tmp table
            $all = $this->$Model->find('list', array('fields' => array('id', 'name')));
            $options['contain'] = array(); # but what if it is a sequence in the conditions?
            $options['fields'] = array();
            foreach ($all as $id => $name) {
                $options['fields'][] = "SUM(IF(`Srna`.`{$model}_id`=$id,1,0)) AS ID_$id";
            }

            $counts = $this->Srna->find('all', $options);
            $counts = $counts[0][0];

            # build the stats array by adding the name belonging to the id
            $stats = array();
            foreach ($counts as $id => $count) {
                $id = substr($id, 3);
                $name = $this->$Model->find('list', array('conditions' => array('id' => $id), 'fields' => array('id', 'name'), 'contain' => false));

                $stats[] = array(
                    'id'   => $id,
                    'name' => $name[$id],
                    'cnt'  => $count
                );
            }
        }

        $this->set(compact('stats'));
    }

    /**
     * Sets $options array to use in pagination for the search and search stats. Gets all its information out of the $this->passedArgs array.
     */
    function _setOptions() {
        $options = array('conditions' => array(), 'contain' => array('Chromosome', 'Type', 'Experiment'), 'countContains' => array());
        foreach ($this->params['named'] as $key => $value) {
            switch ($key) {
            case 'Srna.strand':
                $value = ($value == 0) ? '+' : '-';
            case 'Srna.chromosome_id':
            case 'Srna.type_id':
            case 'Srna.experiment_id':
                $options['conditions'][ $key ] = $value;
                break;
            case 'Srna.start':
            case 'Srna.normalized_abundance_between':
                $options['conditions'][ "$key >=" ] = $value;
                break;
            case 'Srna.stop':
            case 'Srna.normalized_abundance_stop':
                $options['conditions'][ "$key <=" ] = $value;
                break;
            case 'Srna.name':
            case 'Sequence.seq':
//            case 'Annotation.accession_nr':
                $options['conditions'][ "$key LIKE" ] = "%$value%";
                break;
            default:
            }

            switch ($key) {
            case 'Srna.strand':
            case 'Srna.chromosome_id':
            case 'Srna.type_id':
            case 'Srna.experiment_id':
            case 'Srna.start':
            case 'Srna.normalized_abundance_between':
            case 'Srna.stop':
            case 'Srna.normalized_abundance_stop':
            case 'Srna.name':
                break;
            case 'Sequence.seq':
                $options['countContains'][] = 'Sequence';
                $options['contain'][] = 'Sequence';
                break;
            case 'Annotation.accession_nr':
                $options['countContains'][] = 'Mapping.Annotation';
                $options['conditions']["$key LIKE"] = '%'.$this->params['named'][$key].'%';
                $options['joins'][] = array(
                    'table' => 'mappings',
                    'alias' => 'Mapping',
                    'type'  => 'inner',
                    'conditions' => array(
                        'Srna.id = Mapping.srna_id'
                    )
                );
                $options['joins'][] = array(
                    'table' => 'annotations',
                    'alias' => 'Annotation',
                    'type' => 'inner',
                    'conditions' => array(
                        'Annotation.id = Mapping.annotation_id'
                    )
                );
                break;
            default:
            }
        }

        $options['fields'] = array('Srna.id', 'Srna.name', 'Srna.start', 'Srna.stop', 'Srna.strand', 'Chromosome.id', 'Chromosome.name', 'Srna.score', 'Type.id', 'Type.name', 'Srna.abundance', 'Srna.normalized_abundance', 'Experiment.id', 'Experiment.name');

        return $options;
    }

	function add() {
		if (!empty($this->data)) {
			$this->Srna->create();
			if ($this->Srna->save($this->data)) {
				$this->Session->setFlash(__('The srna has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The srna could not be saved. Please, try again.', true));
			}
		}
		#$sequences = $this->Srna->Sequence->find('list');
		$types = $this->Srna->Type->find('list');
		$experiments = $this->Srna->Experiment->find('list');
		$this->set(compact('sequences', 'types', 'experiments'));
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(__('Invalid srna', true));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Srna->save($this->data)) {
				$this->Session->setFlash(__('The srna has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The srna could not be saved. Please, try again.', true));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Srna->read(null, $id);
		}
		$sequences = $this->Srna->Sequence->find('list');
		$types = $this->Srna->Type->find('list');
		$experiments = $this->Srna->Experiment->find('list');
		$this->set(compact('sequences', 'types', 'experiments'));
	}

	function delete($id = null) {
        return;
		if (!$id) {
			$this->Session->setFlash(__('Invalid id for srna', true));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Srna->delete($id)) {
			$this->Session->setFlash(__('Srna deleted', true));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(__('Srna was not deleted', true));
		$this->redirect(array('action' => 'index'));
	}
}
?>
