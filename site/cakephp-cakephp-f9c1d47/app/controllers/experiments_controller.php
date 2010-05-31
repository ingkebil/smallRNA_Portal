<?php
class ExperimentsController extends AppController {

	var $name = 'Experiments';

	function index() {
		$this->Experiment->recursive = 0;
		$this->set('experiments', $this->paginate());
	}

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(sprintf(__('Invalid %s', true), 'experiment'));
			$this->redirect(array('action' => 'index'));
		}
		$this->set('experiment', $this->Experiment->read(null, $id));
	}

	function add() {
		if (!empty($this->data)) {
			$this->Experiment->create();
			if ($this->Experiment->save($this->data)) {
				$this->Session->setFlash(sprintf(__('The %s has been saved', true), 'experiment'));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(sprintf(__('The %s could not be saved. Please, try again.', true), 'experiment'));
			}
		}
		$species = $this->Experiment->Species->find('list');
		$this->set(compact('species'));
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(sprintf(__('Invalid %s', true), 'experiment'));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Experiment->save($this->data)) {
				$this->Session->setFlash(sprintf(__('The %s has been saved', true), 'experiment'));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(sprintf(__('The %s could not be saved. Please, try again.', true), 'experiment'));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Experiment->read(null, $id);
		}
		$species = $this->Experiment->Species->find('list');
		$this->set(compact('species'));
	}

	function delete($id = null) {
		if (!$id) {
			$this->Session->setFlash(sprintf(__('Invalid id for %s', true), 'experiment'));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Experiment->delete($id)) {
			$this->Session->setFlash(sprintf(__('%s deleted', true), 'Experiment'));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(sprintf(__('%s was not deleted', true), 'Experiment'));
		$this->redirect(array('action' => 'index'));
	}
}
?>