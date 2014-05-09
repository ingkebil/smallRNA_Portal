<?php
foreach ($srnas as $srna) {
    echo $srna['Srna']['Chromosome']['name'];
    echo "\t";
    echo "\t";
    echo $srna['Srna']['Type']['name'];
    echo "\t";
    echo $srna['Srna']['start'];
    echo "\t";
    echo $srna['Srna']['stop'];
    echo "\t";
    echo $srna['Srna']['score'];
    echo "\t";
    echo $srna['Srna']['strand'];
    echo "\t";
    echo '.';
    echo "\t";
    echo $srna['Srna']['name'];
    echo "\t\n";
}
?>
