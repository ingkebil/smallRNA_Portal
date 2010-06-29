<?php
class SrnasController extends AppController {

	var $name = 'Srnas';

	function index() {
		$this->Srna->recursive = 0;
		$this->set('srnas', $this->paginate());
	}

    function show(/*$species, $type, $exp*/) {
    }

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid srna', true));
			$this->redirect(array('action' => 'index'));
		}
		$this->set('srna', $this->Srna->read(null, $id));
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
		$sequences = $this->Srna->Sequence->find('list');
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
