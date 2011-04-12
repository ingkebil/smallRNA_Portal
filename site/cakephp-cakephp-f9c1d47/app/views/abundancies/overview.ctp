<?php echo $this->Jquery->paginate_only('overview'); ?>
<div class="srnas">
	<table cellpadding="0" cellspacing="0">
	<tr>
			<th><?php echo $this->Paginator->sort('annotation_id');?></th>
            <?php foreach ($experiments as $exp_id => $exp_name): ?>
            <th><?php echo $this->Paginator->sort($exp_name, "f_$exp_id"); ?></th>
            <?php endforeach; ?>
	</tr>
	<?php
	$i = 0;
	foreach ($abundancies as $abundancy):
		$class = null;
		if ($i++ % 2 == 0) {
			$class = ' class="altrow"';
		}
	?>
	<tr<?php echo $class;?>>
		<td>
			<?php echo $this->Html->link($abundancy['Annotation']['accession_nr'] .'.'. $abundancy['Annotation']['model_nr'], array('controller' => 'annotations', 'action' => 'view', $abundancy['Annotation']['id'])); ?>
        </td>
        <?php foreach ($experiments as $exp_id => $exp_name): ?>
        <td><?php echo $abundancy[0]["f_$exp_id"]; ?></td>
        <?php endforeach; ?>
	</tr>
<?php endforeach; ?>
	</table>
    <?php echo $this->Jquery->paginate_counter('overview'); ?>
</div>
<?php echo $this->Jquery->end_paginate(); ?>
