<div class="srnas index">
	<h2><?php __('Srnas');?></h2>
	<table cellpadding="0" cellspacing="0">
	<tr>
			<th><?php echo $this->Paginator->sort('name');?></th>
			<th><?php echo $this->Paginator->sort('start');?></th>
			<th><?php echo $this->Paginator->sort('stop');?></th>
			<th><?php echo $this->Paginator->sort('strand');?></th>
			<th><?php echo $this->Paginator->sort('score');?></th>
			<th><?php echo $this->Paginator->sort('type_id');?></th>
			<th><?php echo $this->Paginator->sort('abundance');?></th>
			<th><?php echo $this->Paginator->sort('nomalized_abundance');?></th>
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
		<td><?php echo $srna['Srna']['score']; ?>&nbsp;</td>
		<td>
			<?php echo $this->Html->link($srna['Type']['name'], array('controller' => 'types', 'action' => 'view', $srna['Type']['id'])); ?>
		</td>
		<td><?php echo $srna['Srna']['abundance']; ?>&nbsp;</td>
		<td><?php echo $srna['Srna']['nomalized_abundance']; ?>&nbsp;</td>
		<td>
			<?php echo $this->Html->link($srna['Experiment']['name'], array('controller' => 'experiments', 'action' => 'view', $srna['Experiment']['id'])); ?>
		</td>
	</tr>
<?php endforeach; ?>
	</table>
	<p>
	<?php
	echo $this->Paginator->counter(array(
	'format' => __('Page %page% of %pages%, showing %current% records out of %count% total, starting on record %start%, ending on %end%', true)
	));
	?>	</p>

	<div class="paging">
		<?php echo $this->Paginator->prev('<< ' . __('previous', true), array(), null, array('class'=>'disabled'));?>
	 | 	<?php echo $this->Paginator->numbers();?>
 |
		<?php echo $this->Paginator->next(__('next', true) . ' >>', array(), null, array('class' => 'disabled'));?>
	</div>
</div>
