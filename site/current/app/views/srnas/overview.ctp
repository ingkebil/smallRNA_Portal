<?php echo $this->Jquery->paginate_only('overview'); ?>
<div class="srnas">
	<table cellpadding="0" cellspacing="0">
	<tr>
			<th><?php echo $this->Paginator->sort('annotation_id');?></th>
			<th><?php echo $this->Paginator->sort('experiment_id');?></th>
			<th><?php echo $this->Paginator->sort('normalized_abundance');?></th>
			<th><?php echo $this->Paginator->sort('abundance');?></th>
			<th><?php echo $this->Paginator->sort('count');?></th>
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
		<td>
			<?php echo $this->Html->link($abundancy['Experiment']['name'], array('controller' => 'experiments', 'action' => 'view', $abundancy['Experiment']['id'])); ?>
		</td>
		<td><?php echo $abundancy['Abundancy']['normalized_abundance']; ?>&nbsp;</td>
		<td><?php echo $abundancy['Abundancy']['abundance']; ?>&nbsp;</td>
		<td><?php echo $abundancy['Abundancy']['count']; ?>&nbsp;</td>
	</tr>
<?php endforeach; ?>
	</table>
    <?php echo $this->Jquery->paginate_counter('overview'); ?>
</div>
<?php echo $this->Jquery->end_paginate(); ?>
