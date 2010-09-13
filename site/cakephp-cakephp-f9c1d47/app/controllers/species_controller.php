<?php
class SpeciesController extends AppController {

	var $name = 'Species';
    var $components = array('RequestHandler');

	function index() {
		$this->Species->recursive = 0;
		$this->set('species', $this->paginate());
        if ($this->RequestHandler->isAjax()) {
            $this->layout = 'ajax';
        }
	}

    function annotations($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid species', true));
			$this->redirect(array('action' => 'index'));
		}
        if (! is_numeric($id)) {
            $id = $this->Species->find('first', array('conditions' => array('short_name' => $id), 'contain' => false));
            if (! empty($id)) {
                $id = $id['Species']['id'];
            }
        }
        $this->set('annotations', $this->paginate($this->Species->Annotation, array('Annotation.species_id' => $id)));
    }

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid species', true));
			$this->redirect(array('action' => 'index'));
		}
        if (! is_numeric($id)) {
            $id = $this->Species->find('first', array('conditions' => array('short_name' => $id), 'contain' => false));
            if (! empty($id)) {
                $id = $id['Species']['id'];
            }
        }
        $species = $this->Species->find('first', array('conditions' => array('id' => $id), 'contain' => array('Experiment')));
        $this->set('species', $species);
        $this->set('species_id', $species['Species']['id']);
        $this->paginate = array(
            'Annotation' => array(
                'contain' => array('Chromosome', 'Species', 'Source')
            )
        );
        $this->set('annotations', $this->paginate($this->Species->Annotation, array('Annotation.species_id' => $id)));
	}

	function add() {
		if (!empty($this->data)) {
			$this->Species->create();
			if ($this->Species->save($this->data)) {
				$this->Session->setFlash(__('The species has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The species could not be saved. Please, try again.', true));
			}
		}
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(__('Invalid species', true));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Species->save($this->data)) {
				$this->Session->setFlash(__('The species has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The species could not be saved. Please, try again.', true));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Species->read(null, $id);
		}
	}

	function delete($id = null) {
        return;
		if (!$id) {
			$this->Session->setFlash(__('Invalid id for species', true));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Species->delete($id)) {
			$this->Session->setFlash(__('Species deleted', true));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(__('Species was not deleted', true));
		$this->redirect(array('action' => 'index'));
	}
}
?>
