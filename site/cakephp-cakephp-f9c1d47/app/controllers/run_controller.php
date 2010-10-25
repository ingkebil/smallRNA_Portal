<?php

class RunController extends AppController {

    var $uses = array('Blast');

    /**
     * Runs a blast with default params on the default blastdb of sequences
     * 
     */
    function blast($seq = null) {
        $cmd = "blastall -p blastn -d $blastdb -i /tmp/blast.in";

        exec($cmd, $output = array());
    }

}

?>
