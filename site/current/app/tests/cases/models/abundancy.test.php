<?php
/* Abundancy Test cases generated on: 2010-11-01 17:11:02 : 1288629122*/
App::import('Model', 'Abundancy');

class AbundancyTestCase extends CakeTestCase {
	var $fixtures = array('app.abundancy', 'app.annotation', 'app.species', 'app.chromosome', 'app.experiment', 'app.srna', 'app.sequence', 'app.type', 'app.mapping', 'app.source', 'app.structure');

	function startTest() {
		$this->Abundancy =& ClassRegistry::init('Abundancy');
	}

	function endTest() {
		unset($this->Abundancy);
		ClassRegistry::flush();
	}

}
?>