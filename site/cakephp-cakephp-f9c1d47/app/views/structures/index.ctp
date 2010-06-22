<div class="structures index">
	<h2><?php __('Structures');?></h2>
	<table cellpadding="0" cellspacing="0">
	<tr>
			<th><?php echo $this->Paginator->sort('id');?></th>
			<th><?php echo $this->Paginator->sort('annotation_id');?></th>
			<th><?php echo $this->Paginator->sort('start');?></th>
			<th><?php echo $this->Paginator->sort('stop');?></th>
			<th><?php echo $this->Paginator->sort('utr');?></th>
			<th class="actions"><?php __('Actions');?></th>
	</tr>
	<?php
	$i = 0;
	foreach ($structures as $structure):
		$class = null;
		if ($i++ % 2 == 0) {
			$class = ' class="altrow"';
		}
	?>
	<tr<?php echo $class;?>>
		<td><?php echo $structure['Structure']['id']; ?>&nbsp;</td>
		<td>
			<?php echo $this->Html->link($structure['Annotation']['id'], array('controller' => 'annotations', 'action' => 'view', $structure['Annotation']['id'])); ?>
		</td>
		<td><?php echo $structure['Structure']['start']; ?>&nbsp;</td>
		<td><?php echo $structure['Structure']['stop']; ?>&nbsp;</td>
		<td><?php echo $structure['Structure']['utr']; ?>&nbsp;</td>
		<td class="actions">
			<?php echo $this->Html->link(__('View', true), array('action' => 'view', $structure['Structure']['id'])); ?>
			<?php echo $this->Html->link(__('Edit', true), array('action' => 'edit', $structure['Structure']['id'])); ?>
			<?php echo $this->Html->link(__('Delete', true), array('action' => 'delete', $structure['Structure']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $structure['Structure']['id'])); ?>
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
		<li><?php echo $this->Html->link(__('New Structure', true), array('action' => 'add')); ?></li>
		<li><?php echo $this->Html->link(__('List Annotations', true), array('controller' => 'annotations', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Annotation', true), array('controller' => 'annotations', 'action' => 'add')); ?> </li>
	</ul>
</div>