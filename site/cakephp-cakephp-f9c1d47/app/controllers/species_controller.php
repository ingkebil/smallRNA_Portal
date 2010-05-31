<?php
class SpeciesController extends AppController {

	var $name = 'Species';

	function index() {
		$this->Species->recursive = 0;
		$this->set('species', $this->paginate());
	}

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(sprintf(__('Invalid %s', true), 'species'));
			$this->redirect(array('action' => 'index'));
		}
		$this->set('species', $this->Species->read(null, $id));
	}

	function add() {
		if (!empty($this->data)) {
			$this->Species->create();
			if ($this->Species->save($this->data)) {
				$this->Session->setFlash(sprintf(__('The %s has been saved', true), 'species'));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(sprintf(__('The %s could not be saved. Please, try again.', true), 'species'));
			}
		}
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(sprintf(__('Invalid %s', true), 'species'));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Species->save($this->data)) {
				$this->Session->setFlash(sprintf(__('The %s has been saved', true), 'species'));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(sprintf(__('The %s could not be saved. Please, try again.', true), 'species'));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Species->read(null, $id);
		}
	}

	function delete($id = null) {
		if (!$id) {
			$this->Session->setFlash(sprintf(__('Invalid id for %s', true), 'species'));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Species->delete($id)) {
			$this->Session->setFlash(sprintf(__('%s deleted', true), 'Species'));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(sprintf(__('%s was not deleted', true), 'Species'));
		$this->redirect(array('action' => 'index'));
	}
}
?>