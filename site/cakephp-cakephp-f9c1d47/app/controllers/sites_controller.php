<?php

class SitesController extends AppController {

    var $uses = array('Species');
    var $name = 'Sites';

    function index() { }

    /**
     * Will call the /sites/menu and write it to disk.
     * The generation of the menu can take a couple of minutes
     *
     */
    function generate_menu() {
        $msg = 'Success!';
        try {
            $menu = $this->Species->find_species_types_exps();
            file_put_contents(CACHE . 'menu.array', serialize($menu));
        } catch (Exception $ex) {
            $msg = $ex;
        }
        $this->Session->setFlash($msg);
    }

}

?>
