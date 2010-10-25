<?php

class PaginatorComponent extends Object {

    var $components = array('RequestHandler');
    var $controller = false;

	function initialize(&$controller, $settings = array()) {
        $this->controller = $controller;
    }

    function isLazyPage() {
        return ($this->RequestHandler->isAjax() && (isset($this->controller->params['named']['only']) && $this->controller->params['named']['only'] == 'page'));
    }

    function isLazyCount() {
        return ($this->RequestHandler->isAjax() && (isset($this->controller->params['named']['only']) && $this->controller->params['named']['only'] == 'count'));
    }

    function isLazy() {
        return $this->controller->params['named']['only'];
    }

}

?>
