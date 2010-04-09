<?php
class SnrasController extends AppController {

	var $name = 'Snras';

	function index() {
		$this->Snra->recursive = 0;
		$this->set('snras', $this->paginate());
	}

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(sprintf(__('Invalid %s', true), 'snra'));
			$this->redirect(array('action' => 'index'));
		}
		$this->set('snra', $this->Snra->read(null, $id));
	}

	function add() {
		if (!empty($this->data)) {
			$this->Snra->create();
			if ($this->Snra->save($this->data)) {
				$this->Session->setFlash(sprintf(__('The %s has been saved', true), 'snra'));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(sprintf(__('The %s could not be saved. Please, try again.', true), 'snra'));
			}
		}
		$sequences = $this->Snra->Sequence->find('list');
		$types = $this->Snra->Type->find('list');
		$experiments = $this->Snra->Experiment->find('list');
		$this->set(compact('sequences', 'types', 'experiments'));
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(sprintf(__('Invalid %s', true), 'snra'));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Snra->save($this->data)) {
				$this->Session->setFlash(sprintf(__('The %s has been saved', true), 'snra'));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(sprintf(__('The %s could not be saved. Please, try again.', true), 'snra'));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Snra->read(null, $id);
		}
		$sequences = $this->Snra->Sequence->find('list');
		$types = $this->Snra->Type->find('list');
		$experiments = $this->Snra->Experiment->find('list');
		$this->set(compact('sequences', 'types', 'experiments'));
	}

	function delete($id = null) {
		if (!$id) {
			$this->Session->setFlash(sprintf(__('Invalid id for %s', true), 'snra'));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Snra->delete($id)) {
			$this->Session->setFlash(sprintf(__('%s deleted', true), 'Snra'));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(sprintf(__('%s was not deleted', true), 'Snra'));
		$this->redirect(array('action' => 'index'));
	}
}
?>