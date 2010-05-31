<div class="annotations index">
	<h2><?php __('Annotations');?></h2>
	<table cellpadding="0" cellspacing="0">
	<tr>
			<th><?php echo $this->Paginator->sort('id');?></th>
			<th><?php echo $this->Paginator->sort('accession_nr');?></th>
			<th><?php echo $this->Paginator->sort('model_nr');?></th>
			<th><?php echo $this->Paginator->sort('start');?></th>
			<th><?php echo $this->Paginator->sort('stop');?></th>
			<th><?php echo $this->Paginator->sort('strand');?></th>
			<th><?php echo $this->Paginator->sort('chr');?></th>
			<th><?php echo $this->Paginator->sort('type');?></th>
			<th><?php echo $this->Paginator->sort('species_id');?></th>
			<th><?php echo $this->Paginator->sort('seq');?></th>
			<th><?php echo $this->Paginator->sort('comment');?></th>
			<th><?php echo $this->Paginator->sort('source_id');?></th>
			<th class="actions"><?php __('Actions');?></th>
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
		<td><?php echo $annotation['Annotation']['id']; ?>&nbsp;</td>
		<td><?php echo $annotation['Annotation']['accession_nr']; ?>&nbsp;</td>
		<td><?php echo $annotation['Annotation']['model_nr']; ?>&nbsp;</td>
		<td><?php echo $annotation['Annotation']['start']; ?>&nbsp;</td>
		<td><?php echo $annotation['Annotation']['stop']; ?>&nbsp;</td>
		<td><?php echo $annotation['Annotation']['strand']; ?>&nbsp;</td>
		<td><?php echo $annotation['Annotation']['chr']; ?>&nbsp;</td>
		<td><?php echo $annotation['Annotation']['type']; ?>&nbsp;</td>
		<td>
			<?php echo $this->Html->link($annotation['Species']['id'], array('controller' => 'species', 'action' => 'view', $annotation['Species']['id'])); ?>
		</td>
		<td><?php echo $annotation['Annotation']['seq']; ?>&nbsp;</td>
		<td><?php echo $annotation['Annotation']['comment']; ?>&nbsp;</td>
		<td>
			<?php echo $this->Html->link($annotation['Source']['name'], array('controller' => 'sources', 'action' => 'view', $annotation['Source']['id'])); ?>
		</td>
		<td class="actions">
			<?php echo $this->Html->link(__('View', true), array('action' => 'view', $annotation['Annotation']['id'])); ?>
			<?php echo $this->Html->link(__('Edit', true), array('action' => 'edit', $annotation['Annotation']['id'])); ?>
			<?php echo $this->Html->link(__('Delete', true), array('action' => 'delete', $annotation['Annotation']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $annotation['Annotation']['id'])); ?>
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
		<?php echo $this->Paginator->prev('<< '.__('previous', true), array(), null, array('class'=>'disabled'));?>
	 | 	<?php echo $this->Paginator->numbers();?>
 |
		<?php echo $this->Paginator->next(__('next', true).' >>', array(), null, array('class' => 'disabled'));?>
	</div>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Annotation', true)), array('action' => 'add')); ?></li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Species', true)), array('controller' => 'species', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Species', true)), array('controller' => 'species', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Sources', true)), array('controller' => 'sources', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Source', true)), array('controller' => 'sources', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Structures', true)), array('controller' => 'structures', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Structure', true)), array('controller' => 'structures', 'action' => 'add')); ?> </li>
	</ul>
</div>