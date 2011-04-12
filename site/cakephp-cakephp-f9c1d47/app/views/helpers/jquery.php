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
#            'before' => $this->Js->get('#busy-indicator')->effect('fadeIn', array('buffer' => false)),
#            'complete' => $this->Js->get('#busy-indicator')->effect('fadeOut', array('buffer' => false)),
        ),
        $options);
        $this->Paginator->options($options);
        $result = '';
        if (!$this->Ajax->isAjax()) {
            $result = "<div id=\"$id\">";
        }
        return $result;
    }

    function paginate_only($id, $options = array()) {
        $url = $this->params['named'];

        unset($url['only']);
        if (array_key_exists('url', $options)) {
            $options['url'] = array_merge($url, $options['url']);
        }

        return $this->paginate($id, $options);
    }

    function paginate_counter($id, $options = array()) {
        if (!isset($options['busy-indicator'])) {
            $options['busy-indicator'] = $this->Html->image('ajax-loader.gif');
        }
        if (!isset($options['format'])) {
            $options['format'] = "<span class=\"disabled\">%s Counting results ...</span>";
        }

        $url = @$this->Paginator->options['url'];

        $url['only'] = 'count';
        $url['update'] = $id;
        #$url = '/'.implode('/', array_slice(explode('/', Router::url($url)), 2));
        #if (array_key_exists('url', $options)) {
        #    $url = Router::parse($url);
        #    $url = array_merge($url, $options['url']);
        #    $url = '/'.implode('/', array_slice(explode('/', Router::reverse($url)), 2));
        #}

        $result  = "<div id=\"{$this->params['action']}-counting\">";
        $result .= sprintf($options['format'], $options['busy-indicator']);
        $result .= $this->Html->scriptBlock($this->Js->request($url, array('async' => true, 'update' => "#{$this->params['action']}-counting")));
        $result .= '</div>';

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

    function lazy_page($el, $el_options = array(), $jq_options = array()) { 
        $id = $this->_random_link();
        $view =& ClassRegistry::getObject('view');
        $this->paginate("#$id", $jq_options);

        $result  = $this->paginate_only($id, $jq_options);
        $result .= $view->Element($el, $el_options);
        $result .= $this->end_paginate();

        return $result;
    }

    private function _random_link() {
        return 'link-' . rand(0, 2147483647);
    }

}

?>
