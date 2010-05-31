<?php
/* Annotations Test cases generated on: 2010-04-09 15:04:58 : 1270819078*/
App::import('Controller', 'Annotations');

class TestAnnotationsController extends AnnotationsController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class AnnotationsControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.annotation', 'app.species', 'app.source', 'app.structure');

	function startTest() {
		$this->Annotations =& new TestAnnotationsController();
		$this->Annotations->constructClasses();
	}

	function endTest() {
		unset($this->Annotations);
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