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
	</dl>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>
		<li><?php echo $this->Html->link(__('Edit Sequence', true), array('action' => 'edit', $sequence['Sequence']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('Delete Sequence', true), array('action' => 'delete', $sequence['Sequence']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $sequence['Sequence']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('List Sequences', true), array('action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Sequence', true), array('action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Srnas', true), array('controller' => 'srnas', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Srna', true), array('controller' => 'srnas', 'action' => 'add')); ?> </li>
	</ul>
</div>
<div class="related">
	<h3><?php __('Related Srnas');?></h3>
	<?php if (!empty($sequence['Srna'])):?>
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
		foreach ($sequence['Srna'] as $srna):
			$class = null;
			if ($i++ % 2 == 0) {
				$class = ' class="altrow"';
			}
		?>
		<tr<?php echo $class;?>>
			<td><?php echo $srna['id'];?></td>
			<td><?php echo $srna['name'];?></td>
			<td><?php echo $srna['start'];?></td>
			<td><?php echo $srna['stop'];?></td>
			<td><?php echo $srna['strand'];?></td>
			<td><?php echo $srna['sequence_id'];?></td>
			<td><?php echo $srna['score'];?></td>
			<td><?php echo $srna['type_id'];?></td>
			<td><?php echo $srna['abundance'];?></td>
			<td><?php echo $srna['nomalized_abundance'];?></td>
			<td><?php echo $srna['experiment_id'];?></td>
			<td class="actions">
				<?php echo $this->Html->link(__('View', true), array('controller' => 'srnas', 'action' => 'view', $srna['id'])); ?>
				<?php echo $this->Html->link(__('Edit', true), array('controller' => 'srnas', 'action' => 'edit', $srna['id'])); ?>
				<?php echo $this->Html->link(__('Delete', true), array('controller' => 'srnas', 'action' => 'delete', $srna['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $srna['id'])); ?>
			</td>
		</tr>
	<?php endforeach; ?>
	</table>
<?php endif; ?>

	<div class="actions">
		<ul>
			<li><?php echo $this->Html->link(__('New Srna', true), array('controller' => 'srnas', 'action' => 'add'));?> </li>
		</ul>
	</div>
</div>
