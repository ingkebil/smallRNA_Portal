<div class="structures index">
	<h2><?php __('Structures');?></h2>
	<table cellpadding="0" cellspacing="0">
	<tr>
			<th><?php echo $this->Paginator->sort('Annotation', 'Annotation.acession_nr');?></th>
			<th><?php echo $this->Paginator->sort('start');?></th>
			<th><?php echo $this->Paginator->sort('stop');?></th>
			<th><?php echo $this->Paginator->sort('utr');?></th>
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
		<td>
			<?php echo $this->Html->link($structure['Annotation']['accession'], array('controller' => 'annotations', 'action' => 'view', $structure['Annotation']['id'])); ?>
		</td>
		<td><?php echo $structure['Structure']['start']; ?>&nbsp;</td>
		<td><?php echo $structure['Structure']['stop']; ?>&nbsp;</td>
		<td><?php echo $structure['Structure']['utr']; ?>&nbsp;</td>
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
