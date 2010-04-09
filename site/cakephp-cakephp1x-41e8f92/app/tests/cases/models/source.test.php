<?php
/* Source Test cases generated on: 2010-04-09 15:04:26 : 1270819466*/
App::import('Model', 'Source');

class SourceTestCase extends CakeTestCase {
	var $fixtures = array('app.source', 'app.annotation', 'app.species', 'app.structure');

	function startTest() {
		$this->Source =& ClassRegistry::init('Source');
	}

	function endTest() {
		unset($this->Source);
		ClassRegistry::flush();
	}

}
?>