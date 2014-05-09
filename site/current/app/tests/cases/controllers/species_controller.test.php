<?php
/* Species Test cases generated on: 2010-06-22 11:06:02 : 1277197862*/
App::import('Controller', 'Species');

class TestSpeciesController extends SpeciesController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class SpeciesControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.species', 'app.annotation', 'app.source', 'app.structure', 'app.experiment', 'app.srna', 'app.sequence', 'app.type', 'app.types');

	function startTest() {
		$this->Species =& new TestSpeciesController();
		$this->Species->constructClasses();
	}

	function endTest() {
		unset($this->Species);
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