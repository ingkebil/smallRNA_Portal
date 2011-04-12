<?php
/* Abundancies Test cases generated on: 2010-11-01 17:11:02 : 1288629122*/
App::import('Controller', 'Abundancies');

class TestAbundanciesController extends AbundanciesController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class AbundanciesControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.abundancy', 'app.annotation', 'app.species', 'app.chromosome', 'app.experiment', 'app.srna', 'app.sequence', 'app.type', 'app.mapping', 'app.source', 'app.structure', 'app.types');

	function startTest() {
		$this->Abundancies =& new TestAbundanciesController();
		$this->Abundancies->constructClasses();
	}

	function endTest() {
		unset($this->Abundancies);
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