<?php
    echo implode("\t", $experiments) . "\n";
	foreach ($abundancies as $abundancy):
		echo $abundancy['Annotation']['accession_nr'] .'.'. $abundancy['Annotation']['model_nr'] . "\t";
        foreach ($experiments as $exp_id => $exp_name):
            echo $abundancy[0]["f_$exp_id"] . "\t";
        endforeach;
        echo "\n";
    endforeach;
?>
