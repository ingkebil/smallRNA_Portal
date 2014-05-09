<?php

class LinkController extends AnnojAppController {

    var $name = 'Link';
    var $pageTitle = 'AnnoJ';
    var $uses = array('BogasBogas', 'annoj.Contig', 'User', 'Taxid');
    var $helpers = array('Html', 'uri');
	 
    /**
     * To load the layout which loads all the JS
     *
#     */
#   function index($genome = null) {
#        $this->layout = 'annoj';
#        if (! $genome ) {
#            $this->flash('No 5 letter genome name specified!', $this->Session->read('referrer'));
#            return;
#        }
#
#        $this->set('genome', $genome);
#    }
#   
#	
	function conf($genome,$assembly,$position=1,$bases=10) {
	     $this->layout = 'ajax';
		  $name = $genome .".conf.js";
		  $fh = fopen(APP .'plugins/annoj/vendors/js/'.$name, r);
		  $contents = fread($fh, filesize(APP .'plugins/annoj/vendors/js/'.$name));
		  fclose($fh);
     	
		  $Ass_old = "/assembly\s+: '\w+'/";
		  $Ass_new = "assembly : '".$assembly."'";
		  $contents = preg_replace($Ass_old,$Ass_new, $contents);
		  
		  $Pos_old = '/position\s+: \d+/';
		  $Pos_new = 'position : '. $position;
		  $contents = preg_replace($Pos_old,$Pos_new, $contents);
		
		  $bas_old = '/bases\s+: \d+/';
		  $bas_new = 'bases : '. $bases;
		  $contents = preg_replace($bas_old, $bas_new, $contents);
		//print_r($contents);
	    
		 $this->set('response', $contents);
	}

}

?>
