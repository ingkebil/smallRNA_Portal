<?php
/* Type Test cases generated on: 2010-06-22 11:06:11 : 1277197751*/
App::import('Model', 'Type');

class TypeTestCase extends CakeTestCase {
	var $fixtures = array('app.type', 'app.srna', 'app.sequence', 'app.experiment', 'app.species');

	function startTest() {
		$this->Type =& ClassRegistry::init('Type');
	}

	function endTest() {
		unset($this->Type);
		ClassRegistry::flush();
	}

}
?>