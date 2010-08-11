<?php

class RepeatsController extends AnnojAppController {

    var $name = 'Repeats';
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

        if ($genome == 'Ectsi' ){
		  		if ($Namedparam['type'] == 'REPET'){
					$query = "SELECT DISTINCT * FROM repeats WHERE contig_id LIKE '$assembly' AND start <= $right AND end >= $left AND description LIKE 'REPET_%' ORDER BY start ASC, end DESC";
				}
				elseif ( !isset($Namedparam['type']) ){
					$query = "SELECT DISTINCT * FROM repeats WHERE contig_id LIKE '$assembly' AND start <= $right AND end >= $left AND description NOT LIKE 'REPET_%' ORDER BY start ASC, end DESC";
				}
		  }
		  else {
		  		$query = "SELECT DISTINCT * FROM repeats WHERE contig_id LIKE '$assembly' AND start <= $right AND end >= $left ORDER BY start ASC, end DESC";
        }
		  
        $d = mysql_query($query, $this->_connect($genome));
        $data = array(mysql_num_rows($d));

        // iterate the rows
        $count=0;
        while ($r = mysql_fetch_row($d)){
             $length_rep = $r[3]-$r[2];
             if ($genome == 'Ectsi' && $Namedparam['type'] == 'REPET'){
				  	 $data[] = array("","Rep".$r[0],"+","tr",$r[2],$length_rep);   
				 }
				 else {
				    $data[] = array("","Rep".$r[0],"+","mule",$r[2],$length_rep);
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

        $query = "SELECT DISTINCT F.locus_id,F.definition,G.contig,S.START,S.STOP,F.modification_date FROM function AS F JOIN gene AS G USING ( locus_id ) JOIN structure AS S USING ( locus_id ) WHERE F.locus_id = '$locus' ORDER BY F.modification_date DESC LIMIT 1";
        $d = mysql_query($query, $this->_connect($genome));
        $r = mysql_fetch_row($d);

        $query2 = "SELECT DISTINCT modification_date, annotator_id FROM history WHERE locus_id = '$locus' ORDER BY modification_date DESC LIMIT 1";  
        $d2 = mysql_query($query2, $this->_connect($genome));
        $r2 = mysql_fetch_row($d2);

        $full_name = $this->User->find(array('id' => $r2[1]), 'full_name');
        $full_name = $full_name['User']['full_name'];

        $response = array (
            'success' => true,
            'data' => array (
                'id' => $r[0],
                'assembly' => $r[2],
                'start' => $r[3],
                'end' => $r[4],
                'description' => $r[1] . "; Last modified on: ". $r2[0] ." by " .$full_name
            )
        );

        $this->set('response', $response);
    }

    function lookup($genome) {
        $keyword = $this->params['form']['query'];
        $start   = $this->params['form']['start'];
        $limit   = $this->params['form']['limit']; 

        $query = "SELECT DISTINCT id,definition,contig,start,end FROM repeats  
		               WHERE definition like '%$keyword%' OR id like '%$keyword%'
							GROUP BY id
							ORDER BY id ASC, start ASC, stop ASC";

        $d = mysql_query($query, $this->_connect($genome));

        // init  an empty data array
        $result = array();
        $count = mysql_num_rows($d);
        
		  // iterate the rows
        while ($r = mysql_fetch_row($d)){
            $result[] = array (
                'id' => $r[0],
                'assembly' => $r[2],
                'start' => $r[3],
                'end' => $r[4],
                'description' => $r[1]
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
							   'title'     => 'Repeatmasked regions',
							   'species'   => $longgenome['Taxid']['organism'],
								'copyright' => 'Copyright 2008 BEG',
							   'access'    => 'private',
								'version'   => '2008-May-15',
								'format'    => 'Unspecified',
								'server'    => '',
								'description' => 'Regions that are masked by RepeatMasker with <i>'. $longgenome['Taxid']['organism'] .'</i> library of repeats and transposons',
							   )
						)
				);
								
        $this->set('response', $response);
    }

}

?>
