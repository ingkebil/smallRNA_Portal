<?php
class SrnasController extends AppController {

    var $name = 'Srnas';
    var $components = array('RequestHandler', 'Session', 'Paginator');
    var $helpers = array('Ajax', 'Jquery');
    var $uses = array('Srna', 'Type', 'Chromosome', 'Experiment', 'Blast', 'Abundancy');

    function index() {
        $this->paginate = array('Srna' => array('unbindcount' => 1));
        $this->set('srnas', $this->paginate());
    }

    function show(/*$species, $type, $exp*/) {
    }

    function experiment($id) {
        $this->paginate = array('Srna' => array('unbindcount' => 1));
        $this->set('srnas', $this->paginate($this->Srna, array('Experiment_id' => $id)));
    }

    function view($id = null) {
        if (!$id) {
            $this->Session->setFlash(__('Invalid srna', true));
            $this->redirect(array('action' => 'index'));
        }
        $srna = $this->Srna->read(null, $id);
        $this->paginate = array('Annotation' => array('recursive' => 0));
        $annotations = $this->paginate($this->Srna->Experiment->Species->Annotation, array('Annotation.start <=' => $srna['Srna']['start'], 'Annotation.stop >=' => $srna['Srna']['stop'], 'chromosome_id' => $srna['Srna']['chromosome_id']));
        $this->set('annotations', $annotations);
        $this->set('srna', $srna);

        # only render part of the page when requesting it in ajax (only give the related annotions)
        if ($this->RequestHandler->isAjax()) {
            $this->render('_'.$this->renderAction());
        }
    }

    function between($start = 0, $stop = 0, $chr_id = null, $strand = null) {
        if ($this->RequestHandler->isAjax()) {
            $this->layout = 'ajax';
        }
        $this->paginate = array('Mapping' => array('contain' => array('Srna.Chromosome', 'Srna.Type', 'Srna.Experiment')));
        $conds = array('Srna.start >=' => $start, 'Srna.stop <=' => $stop);
        if (!is_null($chr_id)) {
            $conds['Srna.chromosome_id'] = $chr_id;
        }
        if (!is_null($strand)) {
            $strand = $strand == 1 ? '-' : '+';
            $conds['Srna.strand'] = $strand;
        }
        $srnas = $this->paginate_only($this->Srna->Mapping, $conds);
        if (isset($this->params['requested'])){
            return $srnas;
        }
        $this->set('srnas', $srnas);
    }

    /*
     * Give an overview of ALL experiments for a species versus the annotation. At the x you get the abundance for that annotation
     */
    function overview($species = null) {
        #$this->Srna->Mapping->belongsTo['Srna']['order'] = false; # remove annoying table sort
        #$this->paginate = array('Mapping' => array('contain' => array('Srna', 'Annotation'), 'group' => array('Mapping.annotation_id', 'Srna.experiment_id'), 'fields' => array('SUM(Srna.normalized_abundance) AS norm_abundance_count', 'SUM(Srna.abundance) AS abundance_count', 'count(Mapping.srna_id) AS cnt', 'Annotation.accession_nr', 'Annotation.model_nr')));
        #$srnas = $this->paginate_only($this->Srna->Mapping);

        # get the annotations and perform the counts yourself
#        $this->paginate = array('Annotation' => array('contain' => false, 'fields' => array('Annotation.accession_nr', 'Annotation.model_nr', 'Annotation.id', 'Annotation.type')));
#        $annots = $this->paginate_only($this->Srna->Mapping->Annotation);
#
#        # get the srna counts
#        $srnas = array();
#        foreach ($annots as $annot) {
#            $srna_cnts = $this->Srna->Mapping->find('all', array(
#                'conditions' => array('Mapping.annotation_id' => $annot['Annotation']['id']),
#                'fields' => array('SUM(Srna.normalized_abundance) AS norm_abundance_count', 'SUM(Srna.abundance) AS abundance_count', 'count(Mapping.srna_id) AS cnt', 'Srna.experiment_id'),
#                'contain' => array('Srna'),
#                'group' => array('Srna.experiment_id'),
#                'order' => null 
#            ));
#            foreach ($srna_cnts as $srna) {
#                $srna['Annotation'] = $annot['Annotation'];
#                $srnas[] = $srna;
#            }
#        }
#
#        $this->set('experiments', $this->Srna->Experiment->find('list', array('fields' => array('Experiment.id', 'Experiment.name'))));
#        $this->set(compact('srnas'));

        $this->paginate = array('Abundancy' => array('fields' => array('Annotation.accession_nr', 'Annotation.model_nr', 'Experiment.name', 'Experiment.id', 'Abundancy.normalized_abundance', 'Abundancy.abundance', 'Abundancy.count', 'Annotation.id')));
        $this->set('abundancies', $this->paginate_only($this->Abundancy));
    }

    /**
        give a list of reads with their abundances and the count of mapped positions
     */
    function chart($exp_id = null) {
        $exp_id = isset($this->data['Experiment']['experiments']) ? $this->data['Experiment']['experiments'] : $exp_id;
        if ($exp_id) {
            $this->paginate = array(
                'Mapping' => array(
                    'fields' => array('Srna.id', 'Srna.name', 'Srna.start', 'Srna.stop', 'Srna.strand', 'Srna.normalized_abundance', 'count(Mapping.srna_id) AS mapping_count'),
                    'contain' => array('Srna'),
                    'countContains' => array('Srna'),
                    'conditions' => array('Srna.experiment_id' => $exp_id),
                    'group' => array('Srna.id', 'Srna.name', 'Srna.start', 'Srna.stop', 'Srna.strand', 'Srna.normalized_abundance'),
                ),
            );
            $this->set('charts', $this->paginate_only($this->Srna->Mapping));
        }

        $this->set('experiments', $this->Srna->Experiment->find('list'));
    }

    function search() {
        $this->cacheAction = false;
        if (! empty($this->data)) {
            #     [Srna] => Array
            #          (
            #              [chromosome_id] => 
            #              [strand] => 
            #              [type_id] => 
            #              [experiment_id] => 
            #              [start] => 
            #              [stop] => 
            #              [normalized_abundance_between] => 
            #              [normalized_abundance_stop] => 
            #              [sequence_contains] => aaagt
            #          )

            #if (!$this->Srna->validates($this->data)) {
            #    print 'FALSE';
            #}
            $named = $this->_postToGet();
            $named['action'] = 'results';

            $this->redirect($named);
        }
        $types = $this->Srna->Type->find('list');
        $experiments = $this->Srna->Experiment->find('list');
        $chromosomes = $this->Srna->Chromosome->find('list', array('order' => array('name' => 'ASC')));
        $this->set(compact('types', 'experiments', 'chromosomes'));
    }

    function _postToGet($include_model = true) {
        foreach ($this->data as $key => $values) {
            $conditions[ $key ] = array_filter($values, create_function('$a', 'return ! empty($a) || $a == 0;'));
            if (empty($conditions[ $key ])) {
                unset($conditions[ $key ]);
            }
        }
        $named = array();
        foreach ($conditions as $model => $keys) {
            $url_model = $include_model ? urlencode($model) . '.' : '';
            foreach ($keys as $key => $value) {
                $value = preg_replace('/(\s*|\\n|\\r)/', '', $value);
                $url_key   = urlencode($key);
                $url_value = urlencode($value);
                $named[ "$url_model$url_key" ] = $url_value;
            }
        }
        return $named;
    }

    function results() {
        $options = $this->_setOptions();
        $this->paginate = array('Srna' => $options);
        $srnas = $this->paginate_only($this->Srna);
        $this->set('srnas', $srnas);

        # because this view has more than only the pagination, the pagination 
        # code is put into a different view which should only be rendered when we 
        # are displaying the lazy paging part
        if ($this->Paginator->isLazyPage()) {
            $this->render('_' . $this->renderAction());
        }
    }

    function stats($model) {
        $options = $this->_setOptions();

        $model = strtolower($model);
        $Model = ucfirst($model);

        switch ($model) {
        case 'experiment':
        case 'chromosome':
        case 'type':
            # the 'normal' way of doing things takes up to 3 minutes
            #$options['contain'] = array($Model);
            #$options['fields'] = array('COUNT(*) AS cnt', "$Model.id", "$Model.name");
            #$options['group']  = array('Srna.'.$model.'_id');
            #$options['order']  = 'null'; # avoid the unnecessary filesort
            #$stats = $this->Srna->find('all', $options);

            # the 'complex optimized' way avoiding the tmp table
            $all = $this->$Model->find('list', array('fields' => array('id', 'name')));
            $options['contain'] = array(); # but what if it is a sequence in the conditions?
            if (isset($options['conditions']['Sequence.seq LIKE'])) {
                $options['contain'] = array('Sequence');
            }
            $options['fields'] = array();
            foreach ($all as $id => $name) {
                $options['fields'][] = "SUM(IF(`Srna`.`{$model}_id`=$id,1,0)) AS ID_$id";
            }

            $counts = $this->Srna->find('all', $options);
            $counts = $counts[0][0];

            # build the stats array by adding the name belonging to the id
            $stats = array();
            foreach ($counts as $id => $count) {
                $id = substr($id, 3); # remove the added ID_ prefix in the query
                $name = $this->$Model->find('list', array('conditions' => array('id' => $id), 'fields' => array('id', 'name'), 'contain' => false));

                $stats[] = array(
                    'id'   => $id,
                    'name' => $name[$id],
                    'cnt'  => $count
                );
            }
        }

        $this->set(compact('stats'));
    }

    /**
     * Sets $options array to use in pagination for the search and search stats. Gets all its information out of the $this->passedArgs array.
     */
    function _setOptions() {
        $options = array('conditions' => array(), 'contain' => array('Chromosome', 'Type', 'Experiment'), 'countContains' => array());
        foreach ($this->params['named'] as $key => $value) {
            switch ($key) {
            case 'Srna.strand':
                $value = ($value == 0) ? '+' : '-';
            case 'Srna.chromosome_id':
            case 'Srna.type_id':
            case 'Srna.experiment_id':
                $options['conditions'][ $key ] = $value;
                break;
            case 'Srna.start':
                $options['conditions'][ "$key >=" ] = $value;
                break;
            case 'Srna.normalized_abundance_between':
                $options['conditions'][ 'Srna.normalized_abundance >=' ] = $value;
                break;
            case 'Srna.stop':
                $options['conditions'][ "$key <=" ] = $value;
                break;
            case 'Srna.normalized_abundance_stop':
                $options['conditions'][ 'Srna.normalized_abundance <=' ] = $value;
                break;
            case 'Srna.name':
            case 'Sequence.seq':
                //            case 'Annotation.accession_nr':
                #$options['conditions'][ "$key LIKE" ] = "%$value%";
                $hits = $this->Blast->run(array('Sequence' => $key, 'Gapped' => false, 'Expect' => 1));
                $srna_ids = array();
                foreach ($hits['Hit'] as $hit) {
                    foreach ($hit['Srna'] as $srna) {
                        $srna_ids[] = $srna['id'];
                    }
                }
                $options['conditions']['Srna.id'] = $srna_ids;
                break;
            default:
            }

            switch ($key) {
            case 'Srna.strand':
            case 'Srna.chromosome_id':
            case 'Srna.type_id':
            case 'Srna.experiment_id':
            case 'Srna.start':
            case 'Srna.normalized_abundance_between':
            case 'Srna.stop':
            case 'Srna.normalized_abundance_stop':
            case 'Srna.name':
                break;
            case 'Sequence.seq':
                $options['countContains'][] = 'Sequence';
                $options['contain'][] = 'Sequence';
                break;
            case 'Annotation.accession_nr':
                $options['countContains'][] = 'Mapping.Annotation';
                $options['conditions']["$key LIKE"] = '%'.$this->params['named'][$key].'%';
                $options['joins'][] = array(
                    'table' => 'mappings',
                    'alias' => 'Mapping',
                    'type'  => 'inner',
                    'conditions' => array(
                        'Srna.id = Mapping.srna_id'
                    )
                );
                $options['joins'][] = array(
                    'table' => 'annotations',
                    'alias' => 'Annotation',
                    'type' => 'inner',
                    'conditions' => array(
                        'Annotation.id = Mapping.annotation_id'
                    )
                );
                break;
            default:
            }
        }

        $options['fields'] = array('Srna.id', 'Srna.name', 'Srna.start', 'Srna.stop', 'Srna.strand', 'Chromosome.id', 'Chromosome.name', 'Srna.score', 'Type.id', 'Type.name', 'Srna.abundance', 'Srna.normalized_abundance', 'Experiment.id', 'Experiment.name');

        return $options;
    }

    function blast() {
        if (!empty($this->data)) {
            $named = $this->_postToGet(false);
            $named['action'] = 'blasted';

            $this->redirect($named);
        }
    }

    function blasted() {
        $options = $this->_setBlastOptions();
        $session_name = md5(implode('-', $options));
        if ($this->Session->check($session_name)) {
            $result = $this->Session->read($session_name);
            $this->Blast->data($result);
        }
        else {
            $result = $this->Blast->runext($options, true);
        }

        $all_srnas = array();
        $all_degrs = array();
        foreach ($result['Hit'] as $r) {
            $s = array('Srna' => array());
            $s['Srna']['start'] = $r['Srna']['start'];
            $s['Srna']['stop']  = $r['Srna']['stop'];
            $s['Srna']['id']    = $r['Srna']['id'];
            if ($r['Type']['id'] == 1) {
                $all_srnas[] = $s;
            }
            if ($r['Type']['id'] == 2) {
                $all_degrs[] = $s;
            }
        }

        $this->Session->write($session_name, $result);
        $srnas = $this->paginate($this->Blast);
        $this->set(compact('options', 'result', 'all_srnas', 'all_degrs', 'srnas'));
    }

    function blastedsrnas() {
        $options = $this->_setBlastOptions();
        $session_name = md5(implode('-', $options));
        if ($this->Session->check($session_name)) {
            $result = $this->Session->read($session_name);
            $this->Blast->data($result);
        }
        else {
            $result = $this->Blast->runext($options, true);
        }

        $srnas = $this->paginate($this->Blast);
        $this->set(compact('srnas'));
    }

    function _setBlastOptions() {
        $options = array();
        foreach ($this->params['named'] as $key => $value) {
            switch ($key) {
            case 'Sequence': 
                $options[ $key ] = $value;
                break;
            case 'Expect':
                $wl = array('1e-10', '1e-05', '1e-03', '1e-01', 1, 10, 100); # whilelist
                if (!in_array($value, $wl)) {
                    $value = 10;
                }
                $options[ $key ] = $value;
                break;
            case 'Gapped': 
                $options[ $key ] = $value === 1 ? 'T' : 'F';
                break;
            #case 'sort':
            #case 'direction':
            #    $options[ $key ] = $value;
            #    break;
            }

        }

        return $options;
    }

    # some CRUD #

    function add() {
        if (!empty($this->data)) {
            $this->Srna->create();
            if ($this->Srna->save($this->data)) {
                $this->Session->setFlash(__('The srna has been saved', true));
                $this->redirect(array('action' => 'index'));
            } else {
                $this->Session->setFlash(__('The srna could not be saved. Please, try again.', true));
            }
        }
        #$sequences = $this->Srna->Sequence->find('list');
        $types = $this->Srna->Type->find('list');
        $experiments = $this->Srna->Experiment->find('list');
        $this->set(compact('sequences', 'types', 'experiments'));
    }

    function edit($id = null) {
        if (!$id && empty($this->data)) {
            $this->Session->setFlash(__('Invalid srna', true));
            $this->redirect(array('action' => 'index'));
        }
        if (!empty($this->data)) {
            if ($this->Srna->save($this->data)) {
                $this->Session->setFlash(__('The srna has been saved', true));
                $this->redirect(array('action' => 'index'));
            } else {
                $this->Session->setFlash(__('The srna could not be saved. Please, try again.', true));
            }
        }
        if (empty($this->data)) {
            $this->data = $this->Srna->read(null, $id);
        }
        $sequences = $this->Srna->Sequence->find('list');
        $types = $this->Srna->Type->find('list');
        $experiments = $this->Srna->Experiment->find('list');
        $this->set(compact('sequences', 'types', 'experiments'));
    }

    function delete($id = null) {
        return;
        if (!$id) {
            $this->Session->setFlash(__('Invalid id for srna', true));
            $this->redirect(array('action'=>'index'));
        }
        if ($this->Srna->delete($id)) {
            $this->Session->setFlash(__('Srna deleted', true));
            $this->redirect(array('action'=>'index'));
        }
        $this->Session->setFlash(__('Srna was not deleted', true));
        $this->redirect(array('action' => 'index'));
    }
}
?>
