<?php echo $this->Jquery->paginate('related_annotations'); ?>
<div class="annotations">
	<table cellpadding="0" cellspacing="0">
	<tr>
			<th><?php echo $this->Paginator->sort('accession_nr');?></th>
			<th><?php echo $this->Paginator->sort('model_nr');?></th>
			<th><?php echo $this->Paginator->sort('start');?></th>
			<th><?php echo $this->Paginator->sort('stop');?></th>
			<th><?php echo $this->Paginator->sort('strand');?></th>
			<th><?php echo $this->Paginator->sort('Chromosome', 'Chromosome.name');?></th>
			<th><?php echo $this->Paginator->sort('type');?></th>
			<th><?php echo $this->Paginator->sort('Species', 'Species.name');?></th>
			<th><?php echo $this->Paginator->sort('comment');?></th>
			<th><?php echo $this->Paginator->sort('source_id');?></th>
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
		<td><?php echo $this->Html->link($annotation['Annotation']['accession_nr'], array('controller' => 'annotations', 'action' => 'view', $annotation['Annotation']['id'])); ?>&nbsp;</td>
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
<?php echo $this->Jquery->end_paginate(); ?>
