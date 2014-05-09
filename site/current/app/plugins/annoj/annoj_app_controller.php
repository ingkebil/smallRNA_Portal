<?php 

class AnnojAppController extends AppController {

    var $components = array('Session', 'RequestHandler');
    var $helpers = array('Html');
    var $layout = 'json';

    /**
     * Add this content type, as cake hasn't have JSON as default content type
     */
    function beforeFilter() {
        parent::beforeFilter();
#        $this->RequestHandler->setContent('json', 'text/x-json');

#        Configure::write('debug', 0); # json clients don't react too kindly to cake debug output
    }

    function deligate($genome = null) {
        if (! $genome ) {
            $this->flash('No 5 letter genome name specified!', $this->Session->read('referrer'));
            return;
        }

        $action = @$this->params['url']['action'];
        if (! $action ) {
            $action = @$this->params['form']['action'];
        }

        if (method_exists($this, $action)){
            $this->setAction($action, $genome);
        }
        else {
            $this->set('response', array('error' => "$action not found!"));
        }
    }

}

?>
