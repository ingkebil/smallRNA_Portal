<?php
/* Chromosome Test cases generated on: 2010-07-14 10:07:32 : 1279095452*/
App::import('Model', 'Chromosome');

class ChromosomeTestCase extends CakeTestCase {
	var $fixtures = array('app.chromosome', 'app.annotation', 'app.species', 'app.experiment', 'app.srna', 'app.sequence', 'app.type', 'app.source', 'app.structure');

	function startTest() {
		$this->Chromosome =& ClassRegistry::init('Chromosome');
	}

	function endTest() {
		unset($this->Chromosome);
		ClassRegistry::flush();
	}

}
?>