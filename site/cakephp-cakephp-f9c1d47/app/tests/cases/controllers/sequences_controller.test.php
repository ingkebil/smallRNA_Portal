<?php
/* Sequences Test cases generated on: 2010-04-09 15:04:14 : 1270819454*/
App::import('Controller', 'Sequences');

class TestSequencesController extends SequencesController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class SequencesControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.sequence', 'app.snra');

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