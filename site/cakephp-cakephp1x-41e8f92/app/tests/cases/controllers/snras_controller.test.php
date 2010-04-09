<?php
/* Snras Test cases generated on: 2010-04-09 15:04:21 : 1270819461*/
App::import('Controller', 'Snras');

class TestSnrasController extends SnrasController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class SnrasControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.snra', 'app.sequence', 'app.type', 'app.experiment', 'app.species');

	function startTest() {
		$this->Snras =& new TestSnrasController();
		$this->Snras->constructClasses();
	}

	function endTest() {
		unset($this->Snras);
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