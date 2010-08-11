<?php
class SequencesController extends AppController {

	var $name = 'Sequences';
    var $components = array('RequestHandler');

	function index() {
		$this->Sequence->recursive = 0;
		$this->set('sequences', $this->paginate());
	}

    function srna($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid sequence', true));
		}
        if ($this->RequestHandler->isAjax()) {
            $this->layout = 'ajax';
        }
        $this->set('srnas', $this->paginate($this->Sequence->Srna, array('sequence_id' => $id)));
    }

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid sequence', true));
			$this->redirect(array('action' => 'index'));
		}
        $sequence = $this->Sequence->find('first', array('conditions' => array('id' => $id), 'contain' => false));
        $this->set('srnas', $this->paginate($this->Sequence->Srna, array('sequence_id' => $id)));
		$this->set('sequence', $sequence);
	}

	function add() {
		if (!empty($this->data)) {
			$this->Sequence->create();
			if ($this->Sequence->save($this->data)) {
				$this->Session->setFlash(__('The sequence has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The sequence could not be saved. Please, try again.', true));
			}
		}
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(__('Invalid sequence', true));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Sequence->save($this->data)) {
				$this->Session->setFlash(__('The sequence has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The sequence could not be saved. Please, try again.', true));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Sequence->read(null, $id);
		}
	}

	function delete($id = null) {
        return;
		if (!$id) {
			$this->Session->setFlash(__('Invalid id for sequence', true));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Sequence->delete($id)) {
			$this->Session->setFlash(__('Sequence deleted', true));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(__('Sequence was not deleted', true));
		$this->redirect(array('action' => 'index'));
	}
}
?>
