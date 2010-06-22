<?php
/* Sequences Test cases generated on: 2010-06-22 11:06:25 : 1277197645*/
App::import('Controller', 'Sequences');

class TestSequencesController extends SequencesController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class SequencesControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.sequence', 'app.srna', 'app.experiment', 'app.species', 'app.types');

	function startTest() {
		$this->Sequences =& new TestSequencesController();
		$this->Sequences->constructClasses();
	}

	function endTest() {
		unset($this->Sequences);
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