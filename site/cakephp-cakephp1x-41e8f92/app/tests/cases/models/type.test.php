<?php
/* Type Test cases generated on: 2010-04-09 15:04:24 : 1270820244*/
App::import('Model', 'Type');

class TypeTestCase extends CakeTestCase {
	var $fixtures = array('app.type', 'app.snra', 'app.sequence', 'app.experiment', 'app.species', 'app.annotation', 'app.source', 'app.structure');

	function startTest() {
		$this->Type =& ClassRegistry::init('Type');
	}

	function endTest() {
		unset($this->Type);
		ClassRegistry::flush();
	}

}
?>