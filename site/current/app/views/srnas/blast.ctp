<h2>Perform BLAST</h2>
<?php
echo $form->create('Srna');
echo $form->textarea('Sequence'); ?>
Expect: 
<?php echo $form->select('Expect', array('1e-10' => '1e-10', '1e-5' => '1e-5', '1e-03' => '1e-03', '1e-01' => '1e-01', 1 => 1, 10 => 10, 100 => 100), 1); # this is the same list as in model/blast.php ?>
<br />
<br />
<?php echo $form->checkbox('Gapped'); ?>
<label for="SrnaGapped">Perform gapped alignment?</label>
<?php echo $form->end('Blast'); ?>

