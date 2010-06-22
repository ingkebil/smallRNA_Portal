<?php
/* Annotation Test cases generated on: 2010-06-22 11:06:38 : 1277197598*/
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