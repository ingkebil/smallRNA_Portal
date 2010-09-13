<?php
# type
echo $annotation['Chromosome']['name'];
echo "\t";
echo $annotation['Source']['name'];
echo "\t";
echo $annotation['Annotation']['type'];
echo "\t";
echo $annotation['Annotation']['start'];
echo "\t";
echo $annotation['Annotation']['stop'];
echo "\t";
echo '.';
echo "\t";
echo $annotation['Annotation']['strand'];
echo "\t";
echo '.';
echo "\t";
echo 'ID='.$annotation['Annotation']['accession'].';Parent='.$annotation['Annotation']['accession'].';Name='.$annotation['Annotation']['accession'];
echo "\t\n";

if ($annotation['Annotation']['type'] == 'mRNA') {

    # get the stuctures right
    $UTR = array('five_prime_UTR', 'three_prime_UTR');
    $cur_UTR = 0;
    if ($annotation['Annotation']['strand'] == '-') {
        $structures = array_reverse($annotation['Structure']);
        $cur_UTR = 1;
    }
    else {
        $structures = $annotation['Structure'];
    }

    foreach ($structures as $structure) {
        echo $annotation['Chromosome']['name'];
        echo "\t";
        echo $annotation['Source']['name'];
        echo "\t";
        if ($structure['utr'] == 'Y') {
            $type = $UTR[ $cur_UTR ];
        }
        else {
            ++$cur_UTR;
            $cur_UTR %= 2;
            $type = 'CDS';
        }
        echo $type;
        echo "\t";
        echo $structure['start'];
        echo "\t";
        echo $structure['stop'];
        echo "\t";
        echo '.';
        echo "\t";
        echo $annotation['Annotation']['strand'];
        echo "\t";
        echo '.';
        echo "\t";
        echo 'Parent='.$annotation['Annotation']['accession'];
        echo "\t\n";

        echo $annotation['Chromosome']['name'];
        echo "\t";
        echo $annotation['Source']['name'];
        echo "\t";
        echo 'exon';
        echo "\t";
        echo $structure['start'];
        echo "\t";
        echo $structure['stop'];
        echo "\t";
        echo '.';
        echo "\t";
        echo $annotation['Annotation']['strand'];
        echo "\t";
        echo '.';
        echo "\t";
        echo 'Parent='.$annotation['Annotation']['accession'];
        echo "\t\n";
    }
}

echo $this->element('../annotations/gff/srnas', array('srnas' => $srnas));
?>

