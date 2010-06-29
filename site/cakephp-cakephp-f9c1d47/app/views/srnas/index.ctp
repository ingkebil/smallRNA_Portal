<div class="srnas index">
	<h2><?php __('Srnas');?></h2>
	<table cellpadding="0" cellspacing="0">
	<tr>
			<th><?php echo $this->Paginator->sort('id');?></th>
			<th><?php echo $this->Paginator->sort('name');?></th>
			<th><?php echo $this->Paginator->sort('start');?></th>
			<th><?php echo $this->Paginator->sort('stop');?></th>
			<th><?php echo $this->Paginator->sort('strand');?></th>
			<th><?php echo $this->Paginator->sort('sequence_id');?></th>
			<th><?php echo $this->Paginator->sort('score');?></th>
			<th><?php echo $this->Paginator->sort('type_id');?></th>
			<th><?php echo $this->Paginator->sort('abundance');?></th>
			<th><?php echo $this->Paginator->sort('nomalized_abundance');?></th>
			<th><?php echo $this->Paginator->sort('experiment_id');?></th>
			<th class="actions"><?php __('Actions');?></th>
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
		<td><?php echo $srna['Srna']['id']; ?>&nbsp;</td>
		<td><?php echo $srna['Srna']['name']; ?>&nbsp;</td>
		<td><?php echo $srna['Srna']['start']; ?>&nbsp;</td>
		<td><?php echo $srna['Srna']['stop']; ?>&nbsp;</td>
		<td><?php echo $srna['Srna']['strand']; ?>&nbsp;</td>
		<td>
			<?php echo $this->Html->link($srna['Sequence']['id'], array('controller' => 'sequences', 'action' => 'view', $srna['Sequence']['id'])); ?>
		</td>
		<td><?php echo $srna['Srna']['score']; ?>&nbsp;</td>
		<td>
			<?php echo $this->Html->link($srna['Type']['name'], array('controller' => 'types', 'action' => 'view', $srna['Type']['id'])); ?>
		</td>
		<td><?php echo $srna['Srna']['abundance']; ?>&nbsp;</td>
		<td><?php echo $srna['Srna']['nomalized_abundance']; ?>&nbsp;</td>
		<td>
			<?php echo $this->Html->link($srna['Experiment']['name'], array('controller' => 'experiments', 'action' => 'view', $srna['Experiment']['id'])); ?>
		</td>
		<td class="actions">
			<?php echo $this->Html->link(__('View', true), array('action' => 'view', $srna['Srna']['id'])); ?>
			<?php echo $this->Html->link(__('Edit', true), array('action' => 'edit', $srna['Srna']['id'])); ?>
			<?php echo $this->Html->link(__('Delete', true), array('action' => 'delete', $srna['Srna']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $srna['Srna']['id'])); ?>
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
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>
		<li><?php echo $this->Html->link(__('New Srna', true), array('action' => 'add')); ?></li>
		<li><?php echo $this->Html->link(__('List Sequences', true), array('controller' => 'sequences', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Sequence', true), array('controller' => 'sequences', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Types', true), array('controller' => 'types', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Type', true), array('controller' => 'types', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Experiments', true), array('controller' => 'experiments', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Experiment', true), array('controller' => 'experiments', 'action' => 'add')); ?> </li>
	</ul>
</div>