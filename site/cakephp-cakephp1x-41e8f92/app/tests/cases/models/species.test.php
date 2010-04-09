<?php
/* Species Test cases generated on: 2010-04-09 15:04:28 : 1270820068*/
App::import('Model', 'Species');

class SpeciesTestCase extends CakeTestCase {
	var $fixtures = array('app.species', 'app.annotation', 'app.source', 'app.structure', 'app.experiment', 'app.snra', 'app.sequence', 'app.type');

	function startTest() {
		$this->Species =& ClassRegistry::init('Species');
	}

	function endTest() {
		unset($this->Species);
		ClassRegistry::flush();
	}

}
?>