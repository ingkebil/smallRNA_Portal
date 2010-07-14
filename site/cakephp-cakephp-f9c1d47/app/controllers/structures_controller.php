<?php
class StructuresController extends AppController {

	var $name = 'Structures';

	function index() {
		$this->Structure->recursive = 0;
		$this->set('structures', $this->paginate());
	}

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid structure', true));
			$this->redirect(array('action' => 'index'));
		}
		$this->set('structure', $this->Structure->read(null, $id));
	}

	function add() {
		if (!empty($this->data)) {
			$this->Structure->create();
			if ($this->Structure->save($this->data)) {
				$this->Session->setFlash(__('The structure has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The structure could not be saved. Please, try again.', true));
			}
		}
		$annotations = $this->Structure->Annotation->find('list');
		$this->set(compact('annotations'));
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(__('Invalid structure', true));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Structure->save($this->data)) {
				$this->Session->setFlash(__('The structure has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The structure could not be saved. Please, try again.', true));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Structure->read(null, $id);
		}
		$annotations = $this->Structure->Annotation->find('list', array('fields' => array('Annotation.id', 'Annotation.accession')));
		$this->set(compact('annotations'));
	}

	function delete($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid id for structure', true));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Structure->delete($id)) {
			$this->Session->setFlash(__('Structure deleted', true));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(__('Structure was not deleted', true));
		$this->redirect(array('action' => 'index'));
	}
}
?>
