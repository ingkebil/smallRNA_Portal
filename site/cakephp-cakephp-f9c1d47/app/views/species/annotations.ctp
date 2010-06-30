<?php echo $this->Jquery->paginate('related_annots'); ?>
<div class="related">
	<h3><?php __('Related Annotations');?></h3>
	<?php if (!empty($annotations)):?>
	<table cellpadding = "0" cellspacing = "0">
	<tr>
		<th><?php echo $this->Paginator->sort('id'); ?></th>
		<th><?php echo $this->Paginator->sort('accession_nr'); ?></th>
		<th><?php echo $this->Paginator->sort('model_nr'); ?></th>
		<th><?php echo $this->Paginator->sort('start'); ?></th>
		<th><?php echo $this->Paginator->sort('stop'); ?></th>
		<th><?php echo $this->Paginator->sort('strand'); ?></th>
		<th><?php echo $this->Paginator->sort('chr'); ?></th>
		<th><?php echo $this->Paginator->sort('type'); ?></th>
		<th><?php echo $this->Paginator->sort('species_id'); ?></th>
		<th><?php echo $this->Paginator->sort('seq'); ?></th>
		<th><?php echo $this->Paginator->sort('comment'); ?></th>
		<th><?php echo $this->Paginator->sort('source_id'); ?></th>
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
			<td><?php echo $annotation['Annotation']['id'];?></td>
			<td><?php echo $annotation['Annotation']['accession_nr'];?></td>
			<td><?php echo $annotation['Annotation']['model_nr'];?></td>
			<td><?php echo $annotation['Annotation']['start'];?></td>
			<td><?php echo $annotation['Annotation']['stop'];?></td>
			<td><?php echo $annotation['Annotation']['strand'];?></td>
			<td><?php echo $annotation['Annotation']['chr'];?></td>
			<td><?php echo $annotation['Annotation']['type'];?></td>
			<td><?php echo $annotation['Annotation']['species_id'];?></td>
			<td><?php echo $annotation['Annotation']['seq'];?></td>
			<td><?php echo $annotation['Annotation']['comment'];?></td>
			<td><?php echo $annotation['Annotation']['source_id'];?></td>
			<td class="actions">
				<?php echo $this->Html->link(__('View', true), array('controller' => 'annotations', 'action' => 'view', $annotation['Annotation']['id'])); ?>
				<?php echo $this->Html->link(__('Edit', true), array('controller' => 'annotations', 'action' => 'edit', $annotation['Annotation']['id'])); ?>
				<?php echo $this->Html->link(__('Delete', true), array('controller' => 'annotations', 'action' => 'delete', $annotation['Annotation']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $annotation['Annotation']['id'])); ?>
			</td>
		</tr>
	<?php endforeach; ?>
	</table>
	<p>
	<?php
	echo $this->Paginator->counter(array(
	'format' => __('Page %page% of an estimated %pages%, showing %current% records out of an estimated %count% total, starting on record %start%, ending on %end%', true)
	));
	?>	</p>

	<div class="paging">
		<?php echo $this->Paginator->prev('<< ' . __('previous', true), array(), null, array('class'=>'disabled'));?>
	 | 	<?php echo $this->Paginator->numbers();?>
 |
		<?php echo $this->Paginator->next(__('next', true) . ' >>', array(), null, array('class' => 'disabled'));?>
	</div>
<?php endif; ?>

	<div class="actions">
		<ul>
			<li><?php echo $this->Html->link(__('New Annotation', true), array('controller' => 'annotations', 'action' => 'add'));?> </li>
		</ul>
	</div>
</div>
<?php echo $this->Jquery->end_paginate(); ?>
