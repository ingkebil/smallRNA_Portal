<?php 
	$response['data']['description'] .= '<br><br><b>'. $html->link('View Locus in BOGAS','/annotation/'. $genome .'/666666/'. $locus_id, array('target' => 'new')) .'</b>';
	
	echo $javascript->object($response); 

?>
