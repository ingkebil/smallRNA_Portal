<?php
/* Structure Test cases generated on: 2010-04-09 15:04:17 : 1270820237*/
App::import('Model', 'Structure');

class StructureTestCase extends CakeTestCase {
	var $fixtures = array('app.structure', 'app.annotation', 'app.species', 'app.experiment', 'app.snra', 'app.sequence', 'app.type', 'app.source');

	function startTest() {
		$this->Structure =& ClassRegistry::init('Structure');
	}

	function endTest() {
		unset($this->Structure);
		ClassRegistry::flush();
	}

}
?>