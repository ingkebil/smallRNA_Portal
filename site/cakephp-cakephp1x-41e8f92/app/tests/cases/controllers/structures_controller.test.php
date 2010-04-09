<?php
/* Structures Test cases generated on: 2010-04-09 15:04:20 : 1270820240*/
App::import('Controller', 'Structures');

class TestStructuresController extends StructuresController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class StructuresControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.structure', 'app.annotation', 'app.species', 'app.experiment', 'app.snra', 'app.sequence', 'app.type', 'app.source');

	function startTest() {
		$this->Structures =& new TestStructuresController();
		$this->Structures->constructClasses();
	}

	function endTest() {
		unset($this->Structures);
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