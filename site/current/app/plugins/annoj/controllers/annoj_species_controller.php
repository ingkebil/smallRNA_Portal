<?php

class AnnojSpeciesController extends AnnojAppController {

#    var $name = 'AnnojSpecies';
    var $pageTitle = 'AnnoJ';
    var $uses = array('Species', 'Annotation');

    /**
     * To load the layout which loads all the JS
     *
     */

    function index($genome = null) {
        $this->layout = 'annoj';
        if (! $genome ) {
            $this->flash('No 5 letter genome name specified!', '/');
            return;
        }

        $this->set(compact('genome'));
    }

    function syndicate($genome = null) {
        $genome = strtolower($genome);
        $species = $this->Species->find('first', array('conditions' => array('short_name' => $genome), 'contain' => false));
        if ( ! array_key_exists('Species', $species)) {
            $this->flash('None existent genome specified!', '/');
            return;
        }

        # get the contigs or chromosomes ..
        $chrs = $this->Species->Chromosome->get_chr_annoj($species['Species']['id']);

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
                'genome' => array(  
                    'species'  => $species['Species']['full_name'],  
                    'access'   => 'private',  
                    'version'  => '9',  
                    'description' => '',
                    'assemblies'  => $chrs
                )
            )
        );
        $this->set('response', $response);
    }

}

?>
