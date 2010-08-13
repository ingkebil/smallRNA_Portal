<?php
class AnnotationsController extends AppController {

	var $name = 'Annotations';
    var $helpers = array('Jquery', 'Ajax');
    var $components = array('RequestHandler');
    var $uses = array('Annotation');

	function index() {
		$this->Annotation->recursive = 0;
        $this->paginate = array(
            'Annotation' => array(
                'fields' => array('id', 'accession_nr', 'model_nr', 'start', 'stop', 'strand', 'chromosome_id', 'type', 'species_id', 'comment', 'source_id', 'Chromosome.name', 'Species.full_name', 'Species.id', 'Source.name', 'Source.id')
            ),
        );
		$this->set('annotations', $this->paginate());
	}

	function view($id = null) {
		if (!$id) {
			$this->Session->setFlash(__('Invalid annotation', true));
			$this->redirect(array('action' => 'index'));
		}
        $annot = $this->Annotation->read(null, $id);
        $this->paginate = array('Srna' => array('recursive' => 0));
        $srnas = $this->paginate($this->Annotation->Species->Experiment->Srna, array('Srna.start >=' => $annot['Annotation']['start'], 'Srna.stop <=' => $annot['Annotation']['stop'], 'chromosome_id' => $annot['Annotation']['chromosome_id']));
        $this->set('srnas', $srnas);
		$this->set('annotation', $annot);
	}

    function source($id = null) {
        if ($this->RequestHandler->isAjax()) {
            $this->layout = 'ajax';
        }
        $this->paginate = array('Annotation' => array('recursive' => 0));
        $annotations = $this->paginate($this->Annotation, array('source_id' => $id));
        if (isset($this->params['requested'])){
            return $annotations;
        }
        $this->set('annotations', $annotations);
    }

    function between($start = 0, $stop = 0) {
        if ($this->RequestHandler->isAjax()) {
            $this->layout = 'ajax';
        }
        $this->paginate = array('Annotation' => array('recursive' => 0));
        $annotations = $this->paginate($this->Annotation, array('Annotation.start <=' => $start, 'Annotation.stop >=' => $stop));
        if (isset($this->params['requested'])){
            return $annotations;
        }
        $this->set('annotations', $annotations);
    }

	function add() {
		if (!empty($this->data)) {
			$this->Annotation->create();
			if ($this->Annotation->save($this->data)) {
				$this->Session->setFlash(__('The annotation has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The annotation could not be saved. Please, try again.', true));
			}
		}
		$species = $this->Annotation->Species->find('list');
		$sources = $this->Annotation->Source->find('list');
		$chromosomes = $this->Annotation->Chromosome->find('list');
		$this->set(compact('species', 'sources', 'chromosomes'));
	}

	function edit($id = null) {
		if (!$id && empty($this->data)) {
			$this->Session->setFlash(__('Invalid annotation', true));
			$this->redirect(array('action' => 'index'));
		}
		if (!empty($this->data)) {
			if ($this->Annotation->save($this->data)) {
				$this->Session->setFlash(__('The annotation has been saved', true));
				$this->redirect(array('action' => 'index'));
			} else {
				$this->Session->setFlash(__('The annotation could not be saved. Please, try again.', true));
			}
		}
		if (empty($this->data)) {
			$this->data = $this->Annotation->read(null, $id);
		}
		$species = $this->Annotation->Species->find('list');
		$sources = $this->Annotation->Source->find('list');
		$chromosomes = $this->Annotation->Chromosome->find('list');
		$this->set(compact('species', 'sources', 'chromosomes'));
	}

	function delete($id = null) {
        return;
		if (!$id) {
			$this->Session->setFlash(__('Invalid id for annotation', true));
			$this->redirect(array('action'=>'index'));
		}
		if ($this->Annotation->delete($id)) {
			$this->Session->setFlash(__('Annotation deleted', true));
			$this->redirect(array('action'=>'index'));
		}
		$this->Session->setFlash(__('Annotation was not deleted', true));
		$this->redirect(array('action' => 'index'));
	}
}
?>
