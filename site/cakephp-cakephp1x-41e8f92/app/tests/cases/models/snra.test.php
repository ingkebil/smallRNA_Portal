<?php
/* Snra Test cases generated on: 2010-04-09 15:04:19 : 1270819459*/
App::import('Model', 'Snra');

class SnraTestCase extends CakeTestCase {
	var $fixtures = array('app.snra', 'app.sequence', 'app.type', 'app.experiment', 'app.species');

	function startTest() {
		$this->Snra =& ClassRegistry::init('Snra');
	}

	function endTest() {
		unset($this->Snra);
		ClassRegistry::flush();
	}

}
?>