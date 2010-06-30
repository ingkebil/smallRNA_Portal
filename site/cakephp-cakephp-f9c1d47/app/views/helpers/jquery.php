<?php

class JqueryHelper extends AppHelper {

    var $helpers = array('Html', 'Paginator', 'Js', 'Javascript', 'Ajax');

    function beforeRender() {
        $this->Html->script('jquery-1.4.2.min', array('inline' => false, 'once' => true));
    }

    function paginate($id, $options = array()) {
        $options = array_merge(array(
            'update' => "#$id",
            'evalScripts' => true,
            'before' => $this->Js->get('#busy-indicator')->effect('fadeIn', array('buffer' => false)),
            'complete' => $this->Js->get('#busy-indicator')->effect('fadeOut', array('buffer' => false)),
        ),
        $options);
        $this->Paginator->options($options);
        $result = '';
        if (!$this->Ajax->isAjax()) {
            $result = "<div id=\"$id\">";
        }
        return $result;
    }
    
    function end_paginate() { 
        $result = '';
        if (!$this->Ajax->isAjax()) {
            $result = "</div>";
        }
        $result .= $this->Js->writeBuffer();

        return $result;
    }

    function page($el, $el_options = array(), $jq_options = array()) { 
        $id = $this->_random_link();
        $view =& ClassRegistry::getObject('view');
        $this->paginate("#$id", $jq_options);

        $result  = $this->paginate($id, $jq_options);
        $result .= $view->Element($el, $el_options);
        $result .= $this->end_paginate();

        return $result;
    }

    private function _random_link() {
        return 'link-' . rand(0, 2147483647);
    }

}

?>
