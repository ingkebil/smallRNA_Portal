<?php
/* Srnas Test cases generated on: 2010-06-22 11:06:57 : 1277197737*/
App::import('Controller', 'Srnas');

class TestSrnasController extends SrnasController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class SrnasControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.srna', 'app.sequence', 'app.type', 'app.experiment', 'app.species', 'app.types');

	function startTest() {
		$this->Srnas =& new TestSrnasController();
		$this->Srnas->constructClasses();
	}

	function endTest() {
		unset($this->Srnas);
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