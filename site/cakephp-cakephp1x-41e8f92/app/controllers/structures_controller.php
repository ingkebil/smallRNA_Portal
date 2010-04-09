<?php
class StructuresController extends AppController {

	var $name = 'Structures';

	function index() {
		$this->Structure->recursive = 0;
		$this->set('structures', $this->paginate());
	}

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(sprintf(__('Invalid %s', true), 'structure'));
			$this->redirect(array('action' => 'index'));
		}
		$this->set('structure', $this->Structure->read(null, $id));
	}

	function add() {
		if (!empty($this->data)) {
			$this->Structure->create();
			if ($this->Structure->save($this->data)) {
				$this->Session->setFlash(sprintf(__('The %s has been saved', true), 'structure'));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(sprintf(__('The %s could not be saved. Please, try again.', true), 'structure'));
			}
		}
		$annotations = $this->Structure->Annotation->find('list');
		$this->set(compact('annotations'));
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(sprintf(__('Invalid %s', true), 'structure'));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Structure->save($this->data)) {
				$this->Session->setFlash(sprintf(__('The %s has been saved', true), 'structure'));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(sprintf(__('The %s could not be saved. Please, try again.', true), 'structure'));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Structure->read(null, $id);
		}
		$annotations = $this->Structure->Annotation->find('list');
		$this->set(compact('annotations'));
	}

	function delete($id = null) {
		if (!$id) {
			$this->Session->setFlash(sprintf(__('Invalid id for %s', true), 'structure'));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Structure->delete($id)) {
			$this->Session->setFlash(sprintf(__('%s deleted', true), 'Structure'));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(sprintf(__('%s was not deleted', true), 'Structure'));
		$this->redirect(array('action' => 'index'));
	}
}
?>