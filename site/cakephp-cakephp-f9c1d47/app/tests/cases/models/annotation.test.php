<?php
/* Annotation Test cases generated on: 2010-04-09 15:04:55 : 1270819075*/
App::import('Model', 'Annotation');

class AnnotationTestCase extends CakeTestCase {
	var $fixtures = array('app.annotation', 'app.species', 'app.source', 'app.structure');

	function startTest() {
		$this->Annotation =& ClassRegistry::init('Annotation');
	}

	function endTest() {
		unset($this->Annotation);
		ClassRegistry::flush();
	}

}
?>