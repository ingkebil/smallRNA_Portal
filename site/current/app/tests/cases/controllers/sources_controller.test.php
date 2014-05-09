<?php
/* Sources Test cases generated on: 2010-06-22 11:06:31 : 1277197651*/
App::import('Controller', 'Sources');

class TestSourcesController extends SourcesController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class SourcesControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.source', 'app.annotation', 'app.species', 'app.structure', 'app.experiment', 'app.srna', 'app.types');

	function startTest() {
		$this->Sources =& new TestSourcesController();
		$this->Sources->constructClasses();
	}

	function endTest() {
		unset($this->Sources);
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