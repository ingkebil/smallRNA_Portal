<?php

class TilingController extends AnnojAppController {

    var $name = 'Tiling';
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

        $query = "SELECT DISTINCT * FROM tiling_array WHERE contig_id LIKE '$assembly' AND P_start <= $right AND P_stop >= $left ORDER BY P_start ASC, P_stop DESC";

        $d = mysql_query($query, $this->_connect($genome));
        $data = array(mysql_num_rows($d));

        // init  an empty data array
        $values = array();

        // iterate the rows
        while ($r = mysql_fetch_row($d)){
            $length = $r[3]-$r[2];
            $values[] = array($r[2],$length,$r[4]/10,$r[5]/10);

        }
        

     
        // create an associative array with message and data
        $response = array(
            'succes' => true,
            'data'   => array(
                                'CG' => $values,
                                )
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

    function lookup() {
        $keyword = $this->params['form']['query'];
        $start   = $this->params['form']['start'];
        $limit   = $this->params['form']['limit']; 

        $query = "SELECT DISTINCT F.locus_id,F.definition,G.contig,S.START,S.STOP FROM function AS F JOIN gene AS G USING ( locus_id ) JOIN structure AS S USING ( locus_id ) WHERE F.definition like '%$keyword%' GROUP BY S.locus_id ORDER BY S.START ASC, S.STOP DESC LIMIT $start,$limit";

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
							   'title'     => '<i>'.$longgenome['Taxid']['organism'] .'</i> tiling array expression values',
							   'species'   => $longgenome['Taxid']['organism'],
								'copyright' => 'Copyright 2008 BEG',
							   'access'    => 'private',
								'version'   => '2008-May-15',
								'format'    => 'Unspecified',
								'server'    => '',
								'description' => 'The expression value of each probe is depicted in the bar height. The bar above the line denotes the experimental values, the bar underneath the line are the control values.',
							)
					)
			);
        $this->set('response', $response);
    }

}

?>
