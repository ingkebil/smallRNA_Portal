<?php

class EstsController extends AnnojAppController {

    var $name = 'Ests';
    var $pageTitle = 'AnnoJ';
    var $uses = array('BogasBogas', 'annoj.Contig', 'User', 'Taxid');

    /**
     * To load the layout which loads all the JS
     *
     */
    function index($genome = null) {
        $this->layout = 'annoj';
        if (! $genome ) {
            $this->flash('No 5 letter genome name specified!', $this->Session->read('referrer'));
            return;
        }

        $this->set('genome', $genome);
    }

    /**
     * TODO: make it cake
     */
    function range($genome) {

        $Namedparam = Router::getParam('named');

        $assembly = mysql_real_escape_string($this->params['form']['assembly']);
        $bases    = mysql_real_escape_string($this->params['form']['bases']   );
        $left     = mysql_real_escape_string($this->params['form']['left']    );
        $right    = mysql_real_escape_string($this->params['form']['right']   );
        $pixels   = mysql_real_escape_string($this->params['form']['pixels']  );

        //insert queries for diff experiments here
        if ($genome == 'Tetur' ){
            if ($Namedparam['type'] == 'EST'){
                $query = "SELECT DISTINCT est_id, start, stop,map_struct,strand  FROM est WHERE est_id NOT LIKE 'READ%' AND contig_id LIKE '$assembly' AND start <= $right AND stop >= $left ORDER BY start ASC, stop DESC ";
            }
            elseif ($Namedparam['type'] == 'READ'){	
                $query = "SELECT DISTINCT est_id, start, stop,map_struct,strand  FROM est WHERE est_id LIKE 'READ%' AND contig_id LIKE '$assembly' AND start <= $right AND stop >= $left ORDER BY start ASC, stop DESC ";
            }
        }
        elseif ($genome == 'Medtr' ){
            if ($Namedparam['type'] == 'EST'){
                $query = "SELECT DISTINCT est_id, start, stop,map_struct,strand  FROM est WHERE est_id NOT LIKE 'target%' AND contig_id LIKE '$assembly' AND start <= $right AND stop >= $left ORDER BY start ASC, stop DESC ";
            }
            elseif ($Namedparam['type'] == 'READ'){	
                $query = "SELECT DISTINCT est_id, start, stop,map_struct,strand  FROM est WHERE est_id LIKE 'target%' AND contig_id LIKE '$assembly' AND start <= $right AND stop >= $left ORDER BY start ASC, stop DESC ";
            }
        }
        else {
            $query = "SELECT DISTINCT est_id, start, stop,map_struct,strand  FROM est WHERE contig_id LIKE '$assembly' AND start <= $right AND stop >= $left ORDER BY start ASC, stop DESC ";
        }

        $d = mysql_query($query, $this->_connect($genome));
        $rowC = mysql_num_rows($d);
        $data = array($rowC);

        // iterate the rows
        $count=0;
        while ($r = mysql_fetch_row($d)){
            $length_gene = $r[2]-$r[1];
            $data[] = array(null,$r[0],$r[4],"mRNA",$r[1],$length_gene);

            $cdsSPLIT = split ("," , $r[3] );       
            foreach ($cdsSPLIT as $c){
                $coordsCDS = split ("\.\." , $c );
                $length = $coordsCDS[1] - $coordsCDS[0];
                $data[] = array("$r[0]","f"."$count","$r[4]","CDS",$coordsCDS[0],$length);
                $count++;
            }

        }

        // create an associative array with message and data
        $response = array(
            'succes' => true,
            'data'   => $data
        );

        $this->set('response', $response);

    }

    function describe($genome) {
        $locus = $this->params['url']['id'];

        $query = "SELECT DISTINCT est_id,contig_id,start,stop,comment,est_usage FROM est WHERE est_id = '$locus' ORDER BY modification_date DESC LIMIT 1";
        $d = mysql_query($query, $this->_connect($genome));
        $r = mysql_fetch_row($d);

        $desc = '';
        if ($r[4] && $r[4] != 'n/a'){
            $desc = "Comment: " .$r[4] . "; EST supports model: ". $r[5];
        }
        else {
            $desc = "EST supports model: ". $r[5];
        }

        $response = array (
            'success' => true,
            'data' => array (
                'id' => $r[0],
                'assembly' => $r[1],
                'start' => $r[2],
                'end' => $r[3],
                'description' => $desc
            )
        );

        $this->set('response', $response);
    }

    function lookup($genome) {
        $keyword = $this->params['form']['query'];
        $start   = $this->params['form']['start'];
        $limit   = $this->params['form']['limit']; 

        $query = "SELECT DISTINCT est_id,contig_id,start,stop FROM est  
            WHERE est_id like '%$keyword%' 
            GROUP BY est_id
            ORDER BY est_id ASC, start ASC, stop ASC";

        $d = mysql_query($query, $this->_connect($genome));

        // init  an empty data array
        $result = array();
        $count = mysql_num_rows($d);

        // iterate the rows
        while ($r = mysql_fetch_row($d)){
            $result[] = array (
                'id' => $r[0],
                'assembly' => $r[1],
                'start' => $r[2],
                'end' => $r[3],
                'description' => $r[1] .": ". $r[2] ." - ". $r[3]
            );
        }

        $subresult = array_slice  ( $result , $start , $limit);
        $response = array (
            'success' => true,
            'count' => $count,
            'rows' => $subresult
        );

        $this->set('response', $response);
    }

    function syndicate($genome = null, $release = '666666') {
        # get the genome name
        $longgenome = $this->Taxid->findBy5code($genome);
        if (empty($longgenome) || !array_key_exists('Taxid', $longgenome) || !array_key_exists('organism', $longgenome['Taxid'])) {
            $this->flash('None existent genome specified!', '/');
            return;
        }

        # get the genome description
        $conf_array = $this->BogasBogas->find('list', array('conditions' => array('genome' => $genome, 'release' => $release, 'datasource' => 'annotation'), 'fields' => array('key', 'value')) );

        $description = '';
        if (!empty($conf)) {
            $description = $conf['description'];
        }

        $response = array (
            'success' => true,
            'data' => array  (
                'institution' => array (
                    'name' => 'Bioinformatics Ghent University',
                    'url'  => 'http://bioinformatics.psb.ugent.be',
                    'logo' => 'http://bioinformatics.psb.ugent.be/img/logos/beg_logo.png'
                ),
                'engineer' => array (
                    'name'  => 'Lieven Sterck',
                    'email' => 'lieven.sterck@psb.ugent.be'
                ),
                'service' => array (
                    'title'     => '<i>'.$longgenome['Taxid']['organism'] .'</i> transcript mapping',
                    'species'   => $longgenome['Taxid']['organism'],
                    'copyright' => 'Copyright 2008 BEG',
                    'access'    => 'private',
                    'version'   => '2008-May-15',
                    'format'    => 'Unspecified',
                    'server'    => '',
                    'description' => 'ESTs/cDNAs from <i>'. $longgenome['Taxid']['organism'] .'</i> have been mapped to the genome using GenomeThreader.
                    All alignments cover at least 90% of the transcript with min 95% similarity. ',
                )
            )
        );

        $this->set('response', $response);
    }

}

?>
