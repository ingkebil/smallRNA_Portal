<?php if (isset($charts)): ?>
<?php echo $this->Jquery->paginate_only('charts'); ?>
<div class="srnas">
	<table cellpadding="0" cellspacing="0">
	<tr>
			<th><?php echo $this->Paginator->sort('name');?></th>
			<th><?php echo $this->Paginator->sort('normalized_abundance');?></th>
			<th><?php echo $this->Paginator->sort('mapping_count');?></th>
			<th><?php echo $this->Paginator->sort('start');?></th>
			<th><?php echo $this->Paginator->sort('stop');?></th>
	</tr>
	<?php
	$i = 0;
	foreach ($charts as $chart):
		$class = null;
		if ($i++ % 2 == 0) {
			$class = ' class="altrow"';
		}
	?>
	<tr<?php echo $class;?>>
		<td> <?php echo $this->Html->link($chart['Srna']['name'], array('action' => 'view', $chart['Srna']['id'])); ?> </td>
		<td>
            <?php echo $chart['Srna']['normalized_abundance']; ?>
		</td>
		<td><?php echo $chart['0']['mapping_count']; ?>&nbsp;</td>
		<td><?php echo $chart['Srna']['start']; ?>&nbsp;</td>
		<td><?php echo $chart['Srna']['stop']; ?>&nbsp;</td>
	</tr>
<?php endforeach; ?>
	</table>
    <?php echo $this->Jquery->paginate_counter('charts'); ?>
</div>
<?php echo $this->Jquery->end_paginate(); ?>
<?php else: ?>
<div class="srnas form">
<?php echo $this->Form->create('Srna');?>
	<fieldset>
 		<legend><?php __('Pick an experiment'); ?></legend>
	<?php
		echo $this->Form->input('Experiment.experiments');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
<?php endif; ?>
