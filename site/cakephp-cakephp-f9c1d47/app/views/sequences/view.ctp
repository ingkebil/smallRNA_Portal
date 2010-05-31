<div class="sequences view">
<h2><?php  __('Sequence');?></h2>
	<dl><?php $i = 0; $class = ' class="altrow"';?>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Id'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $sequence['Sequence']['id']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Seq'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $sequence['Sequence']['seq']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Seq Hash'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $sequence['Sequence']['seq_hash']; ?>
			&nbsp;
		</dd>
	</dl>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>
		<li><?php echo $this->Html->link(sprintf(__('Edit %s', true), __('Sequence', true)), array('action' => 'edit', $sequence['Sequence']['id'])); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('Delete %s', true), __('Sequence', true)), array('action' => 'delete', $sequence['Sequence']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $sequence['Sequence']['id'])); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Sequences', true)), array('action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Sequence', true)), array('action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Snras', true)), array('controller' => 'snras', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Snra', true)), array('controller' => 'snras', 'action' => 'add')); ?> </li>
	</ul>
</div>
<div class="related">
	<h3><?php printf(__('Related %s', true), __('Snras', true));?></h3>
	<?php if (!empty($sequence['Snra'])):?>
	<table cellpadding = "0" cellspacing = "0">
	<tr>
		<th><?php __('Id'); ?></th>
		<th><?php __('Name'); ?></th>
		<th><?php __('Start'); ?></th>
		<th><?php __('Stop'); ?></th>
		<th><?php __('Strand'); ?></th>
		<th><?php __('Sequence Id'); ?></th>
		<th><?php __('Score'); ?></th>
		<th><?php __('Type Id'); ?></th>
		<th><?php __('Abundance'); ?></th>
		<th><?php __('Nomalized Abundance'); ?></th>
		<th><?php __('Experiment Id'); ?></th>
		<th class="actions"><?php __('Actions');?></th>
	</tr>
	<?php
		$i = 0;
		foreach ($sequence['Snra'] as $snra):
			$class = null;
			if ($i++ % 2 == 0) {
				$class = ' class="altrow"';
			}
		?>
		<tr<?php echo $class;?>>
			<td><?php echo $snra['id'];?></td>
			<td><?php echo $snra['name'];?></td>
			<td><?php echo $snra['start'];?></td>
			<td><?php echo $snra['stop'];?></td>
			<td><?php echo $snra['strand'];?></td>
			<td><?php echo $snra['sequence_id'];?></td>
			<td><?php echo $snra['score'];?></td>
			<td><?php echo $snra['type_id'];?></td>
			<td><?php echo $snra['abundance'];?></td>
			<td><?php echo $snra['nomalized_abundance'];?></td>
			<td><?php echo $snra['experiment_id'];?></td>
			<td class="actions">
				<?php echo $this->Html->link(__('View', true), array('controller' => 'snras', 'action' => 'view', $snra['id'])); ?>
				<?php echo $this->Html->link(__('Edit', true), array('controller' => 'snras', 'action' => 'edit', $snra['id'])); ?>
				<?php echo $this->Html->link(__('Delete', true), array('controller' => 'snras', 'action' => 'delete', $snra['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $snra['id'])); ?>
			</td>
		</tr>
	<?php endforeach; ?>
	</table>
<?php endif; ?>

	<div class="actions">
		<ul>
			<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Snra', true)), array('controller' => 'snras', 'action' => 'add'));?> </li>
		</ul>
	</div>
</div>
