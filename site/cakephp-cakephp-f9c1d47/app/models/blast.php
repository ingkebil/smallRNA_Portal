<?php

class Blast extends AppModel {

    var $useTable = false;
    var $blastdb = '/home/billiau/tmp/arath/srnasblastdb';

    var $_schema = array(
        'name' => array('type' => 'text'),
        'start' => array('type' => 'integer'),
        'stop'  => array('type' => 'integer'),
        'strand' => array('type' => 'string', 'length' => '1'),
        'bitscore' => array('type' => 'float'),
        'type_id' => array('type' => 'integer'),
        'experiment_id' => array('type' => 'integer')
    );

    function runext($options, $cache = false) {
        $cmd_args = array();
        $cmd_args[] = '/usr/bin/blastall -p blastn';
        $cmd_args[] = "-d {$this->blastdb}";
        $cmd_args[] = '-m 7'; # xml output
        
        foreach ($options as $key => $value) {
            $value = str_replace(array("\n", "\r"), '', $value);
            switch ($key) {
            case 'Sequence': 
                $filename = tempnam(TMP, 'srnablast');
                file_put_contents($filename, $value); # TODO include the process # in the filename
                $cmd_args[] = '-i /tmp/blast.in';
                break;
            case 'Gapped':
                $options[ $key ] = $value == 'T' ? 'T' : 'F';
                $cmd_args[] = "-g $value";
                break;
            case 'Expect':
                $wl = array('1e-10', '1e-05', '1e-03', '1e-01', 1, 10, 100); # whilelist
                if (!in_array($value, $wl)) {
                    $value = 10;
                }
                $cmd_args[] = "-e $value";
                break;
            }
        }

        $cmd = implode(' ', $cmd_args);

        $filename = TMP . 'blasts' . DS . md5($cmd);
        $hits = null;
        if ($cache) { # check the cache ?
            if (file_exists($filename)) {
                $opts = file_get_contents($filename, unserialize($filename));

                # make sure we have the right file with the right sequence
                if ($options['Sequence'] == $opts['Sequence']) {
                    $hits = $opts['hits'];
                }
            }
        }
        if (!$hits) {
            exec($cmd, $res);
            $res = implode("\n", $res);
            $hits = $this->hits2srna($this->parse($res));
            if ($cache) {
                $options['hits'] = $hits;
                file_put_contents($filename, serialize($options));
            }
        }

        $this->data = array('Command' => $cmd, 'Hit' => $hits);

        return $this->data;
    }

    /**
     * returns a array(0 => array('Hit' => array('id', 'evalue', 'bitscore', 'alignment'), 'srna' => array('id')));
     */
    function parse($output) {
        $xml = simplexml_load_string($output);
        $hits = $xml->xpath('BlastOutput_iterations/Iteration/Iteration_hits/Hit');

        $results = array();
        foreach ($hits as $name => $hit) {
            $cur = array('Hit' => array(), 'Srna' => array());

            list($cur['Hit']['id'], $srna_ids) = explode('|', (string)$hit->Hit_def);
            $cur['Hit']['evalue'] = (string)$hit->Hit_hsps->Hsp->Hsp_evalue;
            $bit_score = $hit->xpath('Hit_hsps/Hsp/Hsp_bit-score');
            $cur['Hit']['bitscore'] = (string)$bit_score[0];
            $srnas = explode(', ', $srna_ids);
            foreach ($srnas as $srna) {
                $start = $hit->xpath('Hit_hsps/Hsp/Hsp_query-from');
                $stop  = $hit->xpath('Hit_hsps/Hsp/Hsp_query-to');
                $cur_srna = array(
                    'id' => $srna,
                    'start' => (string)$start[0],
                    'stop' => (string)$stop[0],
                );

                $cur_srna['strand'] = '+';
                if ($cur_srna['start'] > $cur_srna['stop']) {
                    $cur_srna['strand'] = '-';
                    $start = $cur_srna['start'];
                    $cur_srna['start'] = $cur_srna['stop'];
                    $cur_srna['stop']  = $start;
                }

                $cur['Srna'][] = $cur_srna;
            }
            $results[] = $cur;
        }

        return $results;
    }

    /**
     * converts the result from parse() to something cake likes
     * Returns an array(0 => array('Srna' => array()));
     */
    function hits2srna($hits) {
        $Srna = ClassRegistry::init('Srna'); # get the Srna model

        $srnas = array();
        foreach ($hits as $hit) {
            foreach ($hit['Srna'] as $srna_hit) {
                $s = $Srna->find('first', array('conditions' => array('Srna.id' => $srna_hit['id']), 'contain' => array('Type', 'Experiment')));

                # 'convert' the coordinates to the querystring coordinates ;)
                $s['Srna']['start'] = $srna_hit['start'];
                $s['Srna']['stop']  = $srna_hit['stop'];
                $s['Hit'] = $hit['Hit'];

                $srnas[] = $s;
            }
        }

        $funsort = create_function('$a,$b', 'return ($a["Srna"]["start"] < $b["Srna"]["start"]) ? -1 : 1;');
        usort($srnas, $funsort);

        return $srnas;
    }

    function paginate($conditions, $fields, $order, $limit = 20, $page = 1, $recursive = null, $extra = array()) {
        if ($this->data) {
            $alias = 'Srna';
            if (is_null($order)) {
                $order = array();
            }
            $order_key = key($order);
			if (strpos($order_key, '.') !== false) {
				list($alias, $field) = explode('.', $order_key);
			}
            if (!isset($field)) {
                $field = 'start';
                $order_sort = '<';
            }
            else {
                # prolly should check which 'alias' we're sorting on
                # but it doesn't matter if it is another 'alias' then
                # we would expect.
                $order_sort = strtolower($order[$order_key]) == 'desc' ? '>' : '<';
            }

            $funsort = create_function('$a,$b', 'return ($a["'.$alias.'"]["'.$field.'"] == $b["'.$alias.'"]["'.$field.'"]) ? 0 : ($a["'.$alias.'"]["'.$field.'"] '.$order_sort.' $b["'.$alias.'"]["'.$field.'"]) ? -1 : 1;');
            $srnas = $this->data['Hit'];
            usort($srnas, $funsort);
            $offset = $page * $limit - $limit;
            return array_slice($srnas, $offset, $limit);
        }
        return false;
    }

    function paginateCount($conditions = null, $recursive = 0, $extra = array()) {
        return $this->data ? count($this->data['Hit']) : false;
    }

    function data($data) {
        if ($data) {
            $this->data = $data;
        }
        return $data;
    }

}

?>
