<?php
class SequencesController extends AppController {

	var $name = 'Sequences';

	function index() {
		$this->Sequence->recursive = 0;
		$this->set('sequences', $this->paginate());
	}

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(sprintf(__('Invalid %s', true), 'sequence'));
			$this->redirect(array('action' => 'index'));
		}
		$this->set('sequence', $this->Sequence->read(null, $id));
	}

	function add() {
		if (!empty($this->data)) {
			$this->Sequence->create();
			if ($this->Sequence->save($this->data)) {
				$this->Session->setFlash(sprintf(__('The %s has been saved', true), 'sequence'));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(sprintf(__('The %s could not be saved. Please, try again.', true), 'sequence'));
			}
		}
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(sprintf(__('Invalid %s', true), 'sequence'));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Sequence->save($this->data)) {
				$this->Session->setFlash(sprintf(__('The %s has been saved', true), 'sequence'));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(sprintf(__('The %s could not be saved. Please, try again.', true), 'sequence'));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Sequence->read(null, $id);
		}
	}

	function delete($id = null) {
		if (!$id) {
			$this->Session->setFlash(sprintf(__('Invalid id for %s', true), 'sequence'));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Sequence->delete($id)) {
			$this->Session->setFlash(sprintf(__('%s deleted', true), 'Sequence'));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(sprintf(__('%s was not deleted', true), 'Sequence'));
		$this->redirect(array('action' => 'index'));
	}
}
?>