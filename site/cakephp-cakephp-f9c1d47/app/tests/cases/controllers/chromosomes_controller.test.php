<?php
/* Chromosomes Test cases generated on: 2010-07-14 12:07:51 : 1279103391*/
App::import('Controller', 'Chromosomes');

class TestChromosomesController extends ChromosomesController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class ChromosomesControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.chromosome', 'app.annotation', 'app.species', 'app.experiment', 'app.srna', 'app.sequence', 'app.type', 'app.source', 'app.structure', 'app.types');

	function startTest() {
		$this->Chromosomes =& new TestChromosomesController();
		$this->Chromosomes->constructClasses();
	}

	function endTest() {
		unset($this->Chromosomes);
		ClassRegistry::flush();
	}

	function testIndex() {

	}

	function testView() {

	}

	function testAdd() {

	}

	function testEdit() {

	}

	function testDelete() {

	}

}
?>