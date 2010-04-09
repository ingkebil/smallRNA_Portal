<?php
/* Species Test cases generated on: 2010-04-09 15:04:28 : 1270820188*/
App::import('Controller', 'Species');

class TestSpeciesController extends SpeciesController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class SpeciesControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.species', 'app.annotation', 'app.source', 'app.structure', 'app.experiment', 'app.snra', 'app.sequence', 'app.type');

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