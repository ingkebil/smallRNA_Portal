<?php
class ChromosomesController extends AppController {

	var $name = 'Chromosomes';
    var $helpers = array('Jquery');
    var $components = array('RequestHandler');

	function index() {
		$this->Chromosome->recursive = 0;
		$this->set('chromosomes', $this->paginate());
	}

    function annotations($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid Chromosome', true));
			$this->redirect(array('action' => 'index'));
		}
        if ($this->RequestHandler->isAjax()) {
            $this->layout = 'ajax';
        }
        $this->set('annotations', $this->paginate($this->Chromosome->Annotation, array('chromosome_id' => $id)));
    }

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid chromosome', true));
			$this->redirect(array('action' => 'index'));
		}
		$this->set('chromosome', $this->Chromosome->read(null, $id));
        $this->set('annotations', $this->paginate($this->Chromosome->Annotation, array('chromosome_id' => $id)));
	}

	function add() {
		if (!empty($this->data)) {
			$this->Chromosome->create();
			if ($this->Chromosome->save($this->data)) {
				$this->Session->setFlash(__('The chromosome has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The chromosome could not be saved. Please, try again.', true));
			}
		}
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(__('Invalid chromosome', true));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Chromosome->save($this->data)) {
				$this->Session->setFlash(__('The chromosome has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The chromosome could not be saved. Please, try again.', true));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Chromosome->read(null, $id);
		}
	}

	function delete($id = null) {
        return;
		if (!$id) {
			$this->Session->setFlash(__('Invalid id for chromosome', true));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Chromosome->delete($id)) {
			$this->Session->setFlash(__('Chromosome deleted', true));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(__('Chromosome was not deleted', true));
		$this->redirect(array('action' => 'index'));
	}
}
?>
