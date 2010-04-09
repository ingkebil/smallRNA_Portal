<?php
/* Sources Test cases generated on: 2010-04-09 15:04:26 : 1270819466*/
App::import('Controller', 'Sources');

class TestSourcesController extends SourcesController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class SourcesControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.source', 'app.annotation', 'app.species', 'app.structure');

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