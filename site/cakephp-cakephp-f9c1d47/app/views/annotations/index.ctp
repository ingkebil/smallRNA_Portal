<div class="annotations index">
	<h2><?php __('Annotations');?></h2>
	<table cellpadding="0" cellspacing="0">
	<tr>
			<th><?php echo $this->Paginator->sort('accession_nr');?></th>
			<th><?php echo $this->Paginator->sort('model_nr');?></th>
			<th><?php echo $this->Paginator->sort('start');?></th>
			<th><?php echo $this->Paginator->sort('stop');?></th>
			<th><?php echo $this->Paginator->sort('strand');?></th>
			<th><?php echo $this->Paginator->sort('Chromosome', 'Chromosome.name');?></th>
			<th><?php echo $this->Paginator->sort('type');?></th>
			<th><?php echo $this->Paginator->sort('Species', 'Species.full_name');?></th>
			<th><?php echo $this->Paginator->sort('comment');?></th>
			<th><?php echo $this->Paginator->sort('Source', 'Source.name');?></th>
			<!--th class="actions"><?php __('Actions');?></th-->
	</tr>
	<?php
	$i = 0;
	foreach ($annotations as $annotation):
		$class = null;
		if ($i++ % 2 == 0) {
			$class = ' class="altrow"';
		}
	?>
	<tr<?php echo $class;?>>
		<td><?php echo $this->Html->link($annotation['Annotation']['accession_nr'], array('action' => 'view', $annotation['Annotation']['id'])); ?>&nbsp;</td>
		<td><?php echo $annotation['Annotation']['model_nr']; ?>&nbsp;</td>
		<td><?php echo $annotation['Annotation']['start']; ?>&nbsp;</td>
		<td><?php echo $annotation['Annotation']['stop']; ?>&nbsp;</td>
		<td><?php echo $annotation['Annotation']['strand']; ?>&nbsp;</td>
		<td><?php echo $annotation['Chromosome']['name']; ?>&nbsp;</td>
		<td><?php echo $annotation['Annotation']['type']; ?>&nbsp;</td>
		<td>
			<?php echo $this->Html->link($annotation['Species']['full_name'], array('controller' => 'species', 'action' => 'view', $annotation['Species']['id'])); ?>
		</td>
		<td><?php echo $annotation['Annotation']['comment']; ?>&nbsp;</td>
		<td>
			<?php echo $this->Html->link($annotation['Source']['name'], array('controller' => 'sources', 'action' => 'view', $annotation['Source']['id'])); ?>
		</td>
		<!--td class="actions">
			<?php $this->Html->link(__('View', true), array('action' => 'view', $annotation['Annotation']['id'])); ?>
			<?php $this->Html->link(__('Edit', true), array('action' => 'edit', $annotation['Annotation']['id'])); ?>
			<?php $this->Html->link(__('Delete', true), array('action' => 'delete', $annotation['Annotation']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $annotation['Annotation']['id'])); ?>
		</td-->
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
		<li><?php echo $this->Html->link(__('New Annotation', true), array('action' => 'add')); ?></li>
		<li><?php echo $this->Html->link(__('List Species', true), array('controller' => 'species', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Species', true), array('controller' => 'species', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Sources', true), array('controller' => 'sources', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Source', true), array('controller' => 'sources', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Structures', true), array('controller' => 'structures', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Structure', true), array('controller' => 'structures', 'action' => 'add')); ?> </li>
	</ul>
</div>
