<?php echo $this->Jquery->paginate('related_srnas'); ?>
<div class="srnas">
	<table cellpadding="0" cellspacing="0">
	<tr>
			<th><?php echo $this->Paginator->sort('name', 'Srna.name');?></th>
			<th><?php echo $this->Paginator->sort('start', 'Srna.start');?></th>
			<th><?php echo $this->Paginator->sort('stop', 'Srna.stop');?></th>
			<th><?php echo $this->Paginator->sort('strand', 'Srna.strand');?></th>
			<th><?php echo $this->Paginator->sort('score', 'Srna.score');?></th>
			<th><?php echo $this->Paginator->sort('type', 'Srna.type_id');?></th>
			<th><?php echo $this->Paginator->sort('experiment', 'Experiment.name');?></th>
	</tr>
	<?php
	$i = 0;
	foreach ($srnas as $srna):
		$class = null;
		if ($i++ % 2 == 0) {
			$class = ' class="altrow"';
		}
	?>
	<tr<?php echo $class;?>>
		<td><?php echo $this->Html->link($srna['Srna']['name'], array('controller' => 'srnas', 'action' => 'view', $srna['Srna']['id'])); ?>&nbsp;</td>
		<td><?php echo $srna['Srna']['start']; ?>&nbsp;</td>
		<td><?php echo $srna['Srna']['stop']; ?>&nbsp;</td>
		<td><?php echo $srna['Srna']['strand']; ?>&nbsp;</td>
		<td><?php echo $srna['Hit']['bitscore']; ?>&nbsp;</td>
		<td>
			<?php echo $this->Html->link($srna['Type']['name'], array('controller' => 'types', 'action' => 'view', $srna['Type']['id'])); ?>
		</td>
		<td>
			<?php echo $this->Html->link($srna['Experiment']['name'], array('controller' => 'experiments', 'action' => 'view', $srna['Experiment']['id'])); ?>
		</td>
	</tr>
<?php endforeach; ?>
	</table>
    <?php echo $this->Jquery->paginate_counter('related_srnas'); ?>
</div>
<?php echo $this->Jquery->end_paginate(); ?>
