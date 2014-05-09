<?php
class AbundanciesController extends AppController {

	var $name = 'Abundancies';

	function index() {
        $this->paginate = array('Abundancy' => array('fields' => array('Annotation.accession_nr', 'Annotation.model_nr', 'Experiment.name', 'Experiment.id', 'Abundancy.normalized_abundance', 'Abundancy.abundance', 'Abundancy.count', 'Annotation.id')));
        $this->set('abundancies', $this->paginate_only($this->Abundancy));
	}

    /**
     * The kind of the same as index, but a different view
     * TODO the count still is wrong!
     * This is how the DB got filled: insert into abundancies select annotation_id, experiment_id, sum(normalized_abundance), sum(abundance), count(s.id) from mappings m join srnas s on m.srna_id = s.id group by annotation_id, experiment_id order by m.annotation_id ASC
     */
    function overview($experiment_id = null) {
        if ($experiment_id) {
            $experiments = $this->Abundancy->Experiment->find('list', array('conditions' => array('Experiment.id' => $experiment_id)));
        }
        else {
            $experiments = $this->Abundancy->Experiment->find('list');
        }
        $this->set(compact('experiments'));
        #$this->paginate = array('Annotation' => array(
        #    'contain' => false,
        #    'joins' => array(
        #        array(
        #            'table' => 'abundancies',
        #            'alias' => 'Abundancy',
        #            'type'  => 'inner',
        #            'conditions' => array(
        #                'Annotation.id = Abundancy.annotation_id'
        #            )
        #        )
        #    ),
        #    'fields' => array(
        #        'Abundancy.normalized_abundance',
        #        'Annotation.id',
        #        'Abundancy.experiment_id'
        #    ),
        #    'group' => array(
        #        'Annotation.id',
        #        'Abundancy.experiment_id'
        #    )
        #));
        #$this->set('abundancies', $this->paginate_only($this->Abundancy->Annotation));
        $this->paginate = array('Abundancy' => array(
            'group' => array(
                'Abundancy.annotation_id',
            ),
            'contain' => array('Annotation'),
            'fields' => array(
                'Annotation.accession_nr',
                'Annotation.model_nr',
                'Annotation.id'
            ),
        ));

        # add the extra fields so we get a exp on the x-axis and annotation on the y-axis
        foreach ($experiments as $id => $name) {
            $this->paginate['Abundancy']['fields'][] = "(select normalized_abundance from abundancies where experiment_id = $id and annotation_id = Abundancy.annotation_id) as f_$id";
            $this->Abundancy->additionalFields[] = "f_$id";
            # because we cannot use aliases in the order by clause of SQL, the above statement is also repeated in the abundancy model
        }
        $abundancies = $this->paginate_only($this->Abundancy);
        $this->set(compact('abundancies'));
    }

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid abundancy', true));
			$this->redirect(array('action' => 'index'));
		}
		$this->set('abundancy', $this->Abundancy->read(null, $id));
	}

	function add() {
		if (!empty($this->data)) {
			$this->Abundancy->create();
			if ($this->Abundancy->save($this->data)) {
				$this->Session->setFlash(__('The abundancy has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The abundancy could not be saved. Please, try again.', true));
			}
		}
		$annotations = $this->Abundancy->Annotation->find('list');
		$experiments = $this->Abundancy->Experiment->find('list');
		$this->set(compact('annotations', 'experiments'));
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(__('Invalid abundancy', true));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Abundancy->save($this->data)) {
				$this->Session->setFlash(__('The abundancy has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The abundancy could not be saved. Please, try again.', true));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Abundancy->read(null, $id);
		}
		$annotations = $this->Abundancy->Annotation->find('list');
		$experiments = $this->Abundancy->Experiment->find('list');
		$this->set(compact('annotations', 'experiments'));
	}

	function delete($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid id for abundancy', true));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Abundancy->delete($id)) {
			$this->Session->setFlash(__('Abundancy deleted', true));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(__('Abundancy was not deleted', true));
		$this->redirect(array('action' => 'index'));
	}
}
?>
