<?php
/* Source Test cases generated on: 2010-06-22 11:06:31 : 1277197651*/
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