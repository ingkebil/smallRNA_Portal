<?php
/* Sequence Test cases generated on: 2010-06-22 11:06:24 : 1277197644*/
App::import('Model', 'Sequence');

class SequenceTestCase extends CakeTestCase {
	var $fixtures = array('app.sequence', 'app.srna');

	function startTest() {
		$this->Sequence =& ClassRegistry::init('Sequence');
	}

	function endTest() {
		unset($this->Sequence);
		ClassRegistry::flush();
	}

}
?>