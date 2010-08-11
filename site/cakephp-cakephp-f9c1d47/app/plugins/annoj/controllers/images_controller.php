<?php

class ImagesController extends AnnojAppController {

    var $name = 'Images';
    var $pageTitle = 'AnnoJ';
    var $uses = array();

    function index($genome = null) {
        $this->layout = 'annoj';
        if (! $genome ) {
            $this->flash('No 5 letter genome name specified!', $this->Session->read('referrer'));
            return;
        }

        $this->set('genome', $genome);
    }

    function image($image = null) {
        $this->layout = 'ajax';
        if (! $image ) {
            $this->flash('No image name specified!', $this->Session->read('referrer'));
            return;
        }

        if ( preg_match('/css/', $this->params['url']['url'] ) ) { //look for images of the css in a diff dir
            $locat = str_replace("annoj/css/img/", "", $this->params['url']['url']);
            $myFile = ROOT .'/app/plugins/annoj/vendors/css/img/'. $locat;
        }
        else {
            $myFile = ROOT .'/app/plugins/'. $this->params['url']['url'];

        }

        $img_extension = end ( split("\.",end( split("/", $this->params['url']['url']) )) );
        $fh = fopen($myFile, 'rb');
        $ImageData = fread($fh, filesize($myFile));
        fclose($fh);

        $this->set('img_ext',$img_extension); 
        $this->set('pic', $ImageData);

    }

}

?>
