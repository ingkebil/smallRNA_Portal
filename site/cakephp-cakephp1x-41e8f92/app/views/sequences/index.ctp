<div class="sequences index">
	<h2><?php __('Sequences');?></h2>
	<table cellpadding="0" cellspacing="0">
	<tr>
			<th><?php echo $this->Paginator->sort('id');?></th>
			<th><?php echo $this->Paginator->sort('seq');?></th>
			<th><?php echo $this->Paginator->sort('seq_hash');?></th>
			<th class="actions"><?php __('Actions');?></th>
	</tr>
	<?php
	$i = 0;
	foreach ($sequences as $sequence):
		$class = null;
		if ($i++ % 2 == 0) {
			$class = ' class="altrow"';
		}
	?>
	<tr<?php echo $class;?>>
		<td><?php echo $sequence['Sequence']['id']; ?>&nbsp;</td>
		<td><?php echo $sequence['Sequence']['seq']; ?>&nbsp;</td>
		<td><?php echo $sequence['Sequence']['seq_hash']; ?>&nbsp;</td>
		<td class="actions">
			<?php echo $this->Html->link(__('View', true), array('action' => 'view', $sequence['Sequence']['id'])); ?>
			<?php echo $this->Html->link(__('Edit', true), array('action' => 'edit', $sequence['Sequence']['id'])); ?>
			<?php echo $this->Html->link(__('Delete', true), array('action' => 'delete', $sequence['Sequence']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $sequence['Sequence']['id'])); ?>
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
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Sequence', true)), array('action' => 'add')); ?></li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Snras', true)), array('controller' => 'snras', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Snra', true)), array('controller' => 'snras', 'action' => 'add')); ?> </li>
	</ul>
</div>