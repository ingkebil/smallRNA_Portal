<?php
/* Experiment Test cases generated on: 2010-06-22 11:06:52 : 1277197612*/
App::import('Model', 'Experiment');

class ExperimentTestCase extends CakeTestCase {
	var $fixtures = array('app.experiment', 'app.species', 'app.srna');

	function startTest() {
		$this->Experiment =& ClassRegistry::init('Experiment');
	}

	function endTest() {
		unset($this->Experiment);
		ClassRegistry::flush();
	}

}
?>