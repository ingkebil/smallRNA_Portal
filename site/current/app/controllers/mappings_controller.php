<?php
class MappingsController extends AppController {

	var $name = 'Mappings';

	function index() {
		$this->Mapping->recursive = 0;
		$this->set('mappings', $this->paginate());
	}

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid mapping', true));
			$this->redirect(array('action' => 'index'));
		}
		$this->set('mapping', $this->Mapping->read(null, $id));
	}

	function add() {
		if (!empty($this->data)) {
			$this->Mapping->create();
			if ($this->Mapping->save($this->data)) {
				$this->Session->setFlash(__('The mapping has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The mapping could not be saved. Please, try again.', true));
			}
		}
		$annotations = $this->Mapping->Annotation->find('list');
		$srnas = $this->Mapping->Srna->find('list');
		$this->set(compact('annotations', 'srnas'));
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(__('Invalid mapping', true));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Mapping->save($this->data)) {
				$this->Session->setFlash(__('The mapping has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The mapping could not be saved. Please, try again.', true));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Mapping->read(null, $id);
		}
		$annotations = $this->Mapping->Annotation->find('list');
		$srnas = $this->Mapping->Srna->find('list');
		$this->set(compact('annotations', 'srnas'));
	}

	function delete($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid id for mapping', true));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Mapping->delete($id)) {
			$this->Session->setFlash(__('Mapping deleted', true));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(__('Mapping was not deleted', true));
		$this->redirect(array('action' => 'index'));
	}
}
?>