<?php
class SourcesController extends AppController {

	var $name = 'Sources';

	function index() {
		$this->Source->recursive = 0;
		$this->set('sources', $this->paginate());
	}

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid source', true));
			$this->redirect(array('action' => 'index'));
		}
        $this->paginate = array('Annotations' => array('recursive' => 0));
        $this->set('annotations', $this->paginate($this->Source->Annotation, array('source_id' => $id)));
		$this->set('source', $this->Source->find('first', array('conditions' => array('id' => $id), 'contain' => false)));
	}

	function add() {
		if (!empty($this->data)) {
			$this->Source->create();
			if ($this->Source->save($this->data)) {
				$this->Session->setFlash(__('The source has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The source could not be saved. Please, try again.', true));
			}
		}
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(__('Invalid source', true));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Source->save($this->data)) {
				$this->Session->setFlash(__('The source has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The source could not be saved. Please, try again.', true));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Source->read(null, $id);
		}
	}

	function delete($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid id for source', true));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Source->delete($id)) {
			$this->Session->setFlash(__('Source deleted', true));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(__('Source was not deleted', true));
		$this->redirect(array('action' => 'index'));
	}
}
?>
