<?php

class MarkersController extends AnnojAppController {

    var $name = 'Markers';
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
        $assembly = mysql_real_escape_string($this->params['form']['assembly']);
        $bases    = mysql_real_escape_string($this->params['form']['bases']   );
        $left     = mysql_real_escape_string($this->params['form']['left']    );
        $right    = mysql_real_escape_string($this->params['form']['right']   );
        $pixels   = mysql_real_escape_string($this->params['form']['pixels']  );

        $query = "SELECT DISTINCT * FROM markers WHERE contig_id LIKE '$assembly' AND start <= $right AND end >= $left ORDER BY start ASC, end DESC"; 

        // execute the query
        $d = mysql_query($query, $this->_connect($genome));
        $data = array(mysql_num_rows($d));

        // iterate the rows
        $count=0;
        while ($r = mysql_fetch_row($d)){
             $length_rep = $r[4]-$r[3];
             $data[] = array("",$r[1],"+","tr",$r[3],$length_rep);
		       //$data[] = array(null,$r[1],"+","mRNA",$r[3],$length_rep);
				 
        }
        

        // create an associative array with message and data
        $response = array(
  		    'succes' => true,
  		    'data'   => $data
  		    );

        
        $this->set('response', $response);
    } 

    function describe($genome) {
        $marker = $this->params['url']['id'];
	 
	     $query = "SELECT DISTINCT marker_id,description,contig_id,start,end FROM markers WHERE marker_id = '$marker' LIMIT 1";
        $d = mysql_query($query, $this->_connect($genome));
        $r = mysql_fetch_row($d);

        $response = array (
           'success' => true,
           'data' => array (
            'id' => $r[0],
            'assembly' => $r[2],
            'start' => $r[3],
            'end' => $r[4],
            'description' => $r[1],
           )
        );

        $this->set('response', $response);
    }

    function lookup($genome) {
        $keyword = $this->params['form']['query'];
        $start   = $this->params['form']['start'];
        $limit   = $this->params['form']['limit']; 

        $query = "SELECT DISTINCT marker_id,description,contig_id,start,end FROM markers 
		               WHERE description like '%$keyword%' OR marker_id like '%$keyword%' 
		               GROUP BY marker_id
							ORDER BY marker_id ASC, start ASC, end ASC ";

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
							   'title'     => 'Genetic marker Track',
							   'species'   => $longgenome['Taxid']['organism'],
								'copyright' => 'Copyright 2008 BEG',
							   'access'    => 'private',
								'version'   => '2008-May-15',
								'format'    => 'Unspecified',
								'server'    => '',
								'description' => 'Genetic markers that can be mapped on the available sequence are denoted in this track',
						)
					)
			);
        $this->set('response', $response);
    }

}

?>
