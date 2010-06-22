<?php
/* Structures Test cases generated on: 2010-06-22 11:06:04 : 1277197744*/
App::import('Controller', 'Structures');

class TestStructuresController extends StructuresController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class StructuresControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.structure', 'app.annotation', 'app.species', 'app.source', 'app.experiment', 'app.srna', 'app.sequence', 'app.type', 'app.types');

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