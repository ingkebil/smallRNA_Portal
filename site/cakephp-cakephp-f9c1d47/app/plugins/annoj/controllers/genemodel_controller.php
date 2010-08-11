<?php

class GenemodelController extends AnnojAppController {

    var $name = 'Genemodel';
    var $pageTitle = 'AnnoJ';
    var $uses = array('Annotation', 'Structure');
    var $helpers = array('Html');
	 
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

    function range($genome) {
        $assembly = $this->params['form']['assembly'];
        $bases    = $this->params['form']['bases']   ;
        $left     = $this->params['form']['left']    ;
        $right    = $this->params['form']['right']   ;
        $pixels   = $this->params['form']['pixels']  ;

        $annots = $this->Annotation->find('all', array('conditions' => array('Annotation.start >=' => $left, 'Annotation.stop <=' => $right, 'Chromosome.name' => $assembly), 'fields' => array('Annotation.accession_nr', 'Annotation.model_nr', 'Annotation.strand', 'Annotation.start', 'Annotation.stop'), 'contain' => array('Structure', 'Chromosome')));

        $data = array();
        foreach ($annots as $annot) {
            $a = $annot['Annotation'];
            $s = $annot['Structure'];

            $data[] = array(null, $a['accession_nr'] . '.' . $a['model_nr'], $a['strand'], 'mRNA', $a['start'], $a['stop'] - $a['start']);
            $c = 1;
            foreach ($s as $exon) {
                $data[] = array(
                    $a['accession_nr'] . '.' . $a['model_nr'],
                    $c++, 
                    $a['strand'],
                    $exon['utr'] == 'Y' ? 'five_prime_UTR' : 'CDS',
                    $exon['start'],
                    $exon['stop'] - $exon['start']
                );
            }
        }

        $response = array(
            'succes' => true,
            'data'   => $data
        );
        $this->set('response', $response);
    }

    function describe($genome) {
        $locus = $this->params['url']['id'];

        $query = "
            SELECT DISTINCT F.locus_id,F.definition,G.contig,S.START,S.STOP,F.modification_date
            FROM function AS F
            JOIN gene AS G USING ( locus_id )
            JOIN structure AS S USING ( locus_id ) 
            WHERE F.locus_id = '$locus'
            ORDER BY F.modification_date DESC LIMIT 1";
        $d = mysql_query($query, $this->_connect($genome));
        $r = mysql_fetch_row($d);

        $query2 = "SELECT DISTINCT modification_date, annotator_id FROM history WHERE locus_id = '$locus' ORDER BY modification_date DESC LIMIT 1";  
        $d2 = mysql_query($query2, $this->_connect($genome));
        $r2 = mysql_fetch_row($d2);

        $full_name = $this->User->find(array('id' => $r2[1]), 'full_name');
        $full_name = $full_name['User']['full_name'];
        
		  
		 //$linkout = $html->url('/annotation/'. $genome .'/666666/'. $locus);
		  $linkout = "http://bioinformatics.psb.ugent.be/webtools/sandbox/liste/BOGAS/trunk/www/site/annotation/".$genome ."/666666/". $locus;
		 // print_r($html->link("/annotation/". $genome ."/666666/". $locus));
		  $response = array (
            'success' => true,
            'data' => array (
                'id' => $r[0],
                'assembly' => $r[2],
                'start' => $r[3],
                'end' => $r[4],
                'description' => $r[1] . '<br> Last modified on: '. $r2[0] .'<br>by: '. $full_name 
            )
        );

        $this->set('response', $response);
		  $this->set('genome' , $genome);
		  $this->set('locus_id', $locus); 
    }

    function lookup($genome) {
        $keyword = $this->params['form']['query'];
        $start   = $this->params['form']['start'];
        $limit   = $this->params['form']['limit']; 

        $query = "SELECT DISTINCT F.locus_id,F.definition,G.contig,S.START,S.STOP FROM function AS F 
		             JOIN gene AS G USING ( locus_id ) 
						 JOIN structure AS S USING ( locus_id )
						 JOIN locked AS L USING ( locus_id )  
						 WHERE L.status <> 'inactive' AND F.definition like '%$keyword%' OR G.locus_id like '%$keyword%'
						 GROUP BY S.locus_id 
						 ORDER BY S.locus_id, S.START ASC, S.STOP DESC ";

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

    function syndicate($genome = null) {
        $genome = strtolower($genome);
        $species = $this->Species->find('first', array('conditions' => array('short_name' => $genome), 'contain' => false));
        if ( ! array_key_exists('Species', $species)) {
            $this->flash('None existent genome specified!', '/');
            return;
        }

        $response = array (
            'success' => true,
            'data' => array  (
                'institution' => array (
                    'name' => 'Bioinformatics AG Walther',
                    'url'  => 'http://bioinformatics.mpimp-golm.mpg.de',
                    'logo' => 'http://www.mpimp-golm.mpg.de/portal_img/mpimp_logo_150x69.png'
                ),
                'engineer' => array (
                    'name'  => 'Kenny Billiau',
                    'email' => 'billiau@mpimp-golm.mpg.de'
                ),
                'service' => array (
                    'title'     => 'smallRNA DB' . $species['Species']['full_name'],
                    'species'   => $species['Species']['full_name'],
                    'copyright' => 'Copyright 2010 MPG',
                    'access'    => 'private',
                    'version'   => '',
                    'format'    => 'Unspecified',
                    'server'    => '',
                    'description' => '',
                ),
            )
        );
        $this->set('response', $response);
    }

#    function information() {
#        $response = array
#            (
#                'success' => true,
#                'data' => array(
#                    'institution' => array(
#                        'name' => 'Bioinformatics Ghent University',
#                        'url'  => 'http://bioinformatics.psb.ugent.be',
#                        'logo' => 'http://bioinformatics.psb.ugent.be/img/logos/beg_logo.png'
#                    ),
#                    'curator' => array(
#                        'name'  => 'liste',
#                        'email' => 'liste@psb.ugent.be'
#                    ),
#                    'service' => array(
#                        'title'     => 'Solanum lycopersicum',
#                        'copyright' => 'Copyright 2008 BEG',
#                        'license'   => 'http://creativecommons.org',
#                        'version'   => '2008-May-15',
#                        'details'   => 'Gene-model annotations',
#                    ),
#                    'genome' => array(  
#                        'species'  => 'Solanum lycopersicum',  
#                        'access'   => 'public',  
#                        'version'  => '8',  
#                        'description' => 'Release 8 maintained by TAIR',
#                        'assemblies'  => array(  
#                            array('id' => 'sctg_0','size' => '148257')
#                        )
#                    )
#                )
#            );
#        $this->set('response', $response);
#    }

}

?>
