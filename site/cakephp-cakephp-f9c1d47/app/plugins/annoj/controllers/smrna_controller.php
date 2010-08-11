<?php

class SmrnaController extends AnnojAppController {

    var $name = 'Smrna';
    var $pageTitle = 'AnnoJ';
    var $uses = array('BogasBogas', 'annoj.Contig', 'User', 'Taxid');

    /**
     * To load the layout which loads all the JS
     *
     */
   function index($genome = null ) {
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
		  if ($Namedparam['type'] == 'gameto'){
		  	
			   $query = "SELECT DISTINCT * FROM deep_seq_rna WHERE contig_id LIKE '$assembly' AND start <= $right AND stop >= $left AND rna_id LIKE 'h%' ORDER BY start ASC, stop DESC"; 
		  }
		  elseif ($Namedparam['type'] == 'sporo'){
		      $query = "SELECT DISTINCT * FROM deep_seq_rna WHERE contig_id LIKE '$assembly' AND start <= $right AND stop >= $left AND rna_id LIKE 'i%' ORDER BY start ASC, stop DESC"; 
		  }
		  else {
		      $query = "SELECT DISTINCT * FROM deep_seq_rna WHERE contig_id LIKE '$assembly' AND start <= $right AND stop >= $left ORDER BY start ASC, stop DESC"; 
        }
 
        // execute the query
        $d = mysql_query($query,$this->_connect($genome));

        // init  an empty data array
        $Wvalues = array();
        $Cvalues = array();
	 
        // iterate the rows
     
	     if ($bases >= 10){ //return stacks info in stead of real seq
	         while ($r = mysql_fetch_row($d)){
                 $length = ($r[4]-$r[3]) +1;
				     if ($r[5] == '+'){
				         $values[] = array($r[3],$length,$r[6],'0');
				     }
				     else {
				      	$values[] = array($r[3],$length,'0',$r[6]);
				     }
		      }
		
		      $response = array(
  		          'succes' => true,
  		          'data'   => array(
                                'read' => $values,
                                ),
							'type' => $type
  		           );

	     }
	     else {
	          while ($r = mysql_fetch_row($d)){
                  $length = ($r[4]-$r[3]) +1;
                  if ($r[5] == '+'){
		                if ($pixels > 1){ // response with seq  
						        $Wvalues[] = array($r[1],$r[3]+0,$length,$r[6]+0,1,$r[7]);
						    }
						    else { //response without actual seq
						        $Wvalues[] = array($r[1],$r[3]+0,$length,$r[6]+0,1,'');
						    }
		            }
		            else {
		                if ($pixels > 1){
						        $Cvalues[] = array($r[1],$r[3]+0,$length,$r[6]+0,1,$r[7]);
						    }
						    else {
						        $Cvalues[] = array($r[1],$r[3]+0,$length,$r[6]+0,1,'');
						    }
		            }
		       }

             $response = array(
  		             'succes' => true,
  		             'data'   => array(
			                    'read' => array(
                                   'watson' => $Wvalues,
										     'crick' => $Cvalues,
                              )
							      )
  		       );
				 
        }
   
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
   /*
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
    */
    function syndicate($genome = null, $release = '666666') {
        $Namedparam = Router::getParam('named');
				   
	     if ($Namedparam['type'] == 'gameto'){
		  	  $sampleName = 'gametophyte';
		  }
		  elseif ($Namedparam['type'] == 'sporo'){
		     $sampleName = 'sporophyte'; 
		  }
		  
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
							   'title'     => 'Small RNA deep sequencing Track',
							   'species'   => $longgenome['Taxid']['organism'],
								'copyright' => 'Copyright 2008 BEG',
							   'access'    => 'private',
								'version'   => '2008-May-15',
								'format'    => 'Unspecified',
								'server'    => '',
								'description' => 'Deep sequencing of small RNAs isolated from <i>'. $longgenome['Taxid']['organism'] .'</i> '. $sampleName ,
						)
				)
		  );
        $this->set('response', $response);
    }

    function gameto (){
	 	print_r($type);
	 }
}

?>
