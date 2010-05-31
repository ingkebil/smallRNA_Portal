<?php
class AnnotationsController extends AppController {

	var $name = 'Annotations';

	function index() {
		$this->Annotation->recursive = 0;
		$this->set('annotations', $this->paginate());
	}

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(sprintf(__('Invalid %s', true), 'annotation'));
			$this->redirect(array('action' => 'index'));
		}
		$this->set('annotation', $this->Annotation->read(null, $id));
	}

	function add() {
		if (!empty($this->data)) {
			$this->Annotation->create();
			if ($this->Annotation->save($this->data)) {
				$this->Session->setFlash(sprintf(__('The %s has been saved', true), 'annotation'));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(sprintf(__('The %s could not be saved. Please, try again.', true), 'annotation'));
			}
		}
		$species = $this->Annotation->Species->find('list');
		$sources = $this->Annotation->Source->find('list');
		$this->set(compact('species', 'sources'));
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(sprintf(__('Invalid %s', true), 'annotation'));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Annotation->save($this->data)) {
				$this->Session->setFlash(sprintf(__('The %s has been saved', true), 'annotation'));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(sprintf(__('The %s could not be saved. Please, try again.', true), 'annotation'));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Annotation->read(null, $id);
		}
		$species = $this->Annotation->Species->find('list');
		$sources = $this->Annotation->Source->find('list');
		$this->set(compact('species', 'sources'));
	}

	function delete($id = null) {
		if (!$id) {
			$this->Session->setFlash(sprintf(__('Invalid id for %s', true), 'annotation'));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Annotation->delete($id)) {
			$this->Session->setFlash(sprintf(__('%s deleted', true), 'Annotation'));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(sprintf(__('%s was not deleted', true), 'Annotation'));
		$this->redirect(array('action' => 'index'));
	}
}
?>