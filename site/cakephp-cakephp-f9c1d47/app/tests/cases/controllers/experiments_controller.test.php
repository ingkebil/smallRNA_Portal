<?php
/* Experiments Test cases generated on: 2010-06-22 11:06:02 : 1277197622*/
App::import('Controller', 'Experiments');

class TestExperimentsController extends ExperimentsController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class ExperimentsControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.experiment', 'app.species', 'app.srna', 'app.types');

	function startTest() {
		$this->Experiments =& new TestExperimentsController();
		$this->Experiments->constructClasses();
	}

	function endTest() {
		unset($this->Experiments);
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