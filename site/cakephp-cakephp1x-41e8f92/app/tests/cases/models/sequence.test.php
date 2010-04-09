<?php
/* Sequence Test cases generated on: 2010-04-09 15:04:03 : 1270819443*/
App::import('Model', 'Sequence');

class SequenceTestCase extends CakeTestCase {
	var $fixtures = array('app.sequence', 'app.snra');

	function startTest() {
		$this->Sequence =& ClassRegistry::init('Sequence');
	}

	function endTest() {
		unset($this->Sequence);
		ClassRegistry::flush();
	}

}
?>