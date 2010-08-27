<?php
/* Mapping Test cases generated on: 2010-08-20 17:08:53 : 1282318553*/
App::import('Model', 'Mapping');

class MappingTestCase extends CakeTestCase {
	var $fixtures = array('app.mapping', 'app.annotation', 'app.species', 'app.chromosome', 'app.experiment', 'app.srna', 'app.sequence', 'app.type', 'app.source', 'app.structure');

	function startTest() {
		$this->Mapping =& ClassRegistry::init('Mapping');
	}

	function endTest() {
		unset($this->Mapping);
		ClassRegistry::flush();
	}

}
?>