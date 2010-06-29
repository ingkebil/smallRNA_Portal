<?php

class JqueryHelper extends AppHelper {

    var $helpers = array('Html', 'Paginator', 'Js', 'Javascript');

    function beforeRender() {
        $this->Html->script('jquery-1.4.2.min', array('inline' => false, 'once' => true));
    }

    function paginate($id, $options = array()) {
        $options = array_merge(array(
            'update' => $id,
            'evalScripts' => true,
            'before' => $this->Js->get('#busy-indicator')->effect('fadeIn', array('buffer' => false)),
            'complete' => $this->Js->get('#busy-indicator')->effect('fadeOut', array('buffer' => false)),
        ),
        $options);
        $this->Paginator->options($options);
    }

}

?>
