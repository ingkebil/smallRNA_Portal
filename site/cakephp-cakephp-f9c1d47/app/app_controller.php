<?php

class AppController extends Controller {

    var $uses = array('Experiment', 'Species', 'Types');

    function beforeRender() {
        parent::beforeRender();

        if ( ! file_exists(CACHE . 'menu.array')) {
            $menu = $this->Species->find_species_types_exps();
            file_put_contents(CACHE . 'menu.array', serialize($menu));
        }

        $menu = unserialize(file_get_contents(CACHE . 'menu.array'));
        $this->set('site_menu', $menu);
    }
}
?>
