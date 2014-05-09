<?php
/* Mappings Test cases generated on: 2010-08-20 17:08:53 : 1282318553*/
App::import('Controller', 'Mappings');

class TestMappingsController extends MappingsController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class MappingsControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.mapping', 'app.annotation', 'app.species', 'app.chromosome', 'app.experiment', 'app.srna', 'app.sequence', 'app.type', 'app.source', 'app.structure', 'app.types');

	function startTest() {
		$this->Mappings =& new TestMappingsController();
		$this->Mappings->constructClasses();
	}

	function endTest() {
		unset($this->Mappings);
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