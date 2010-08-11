<div class="types view">
<h2><?php  __('Type');?></h2>
	<dl><?php $i = 0; $class = ' class="altrow"';?>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Id'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $type['Type']['id']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Name'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $type['Type']['name']; ?>
			&nbsp;
		</dd>
	</dl>
</div>
<div class="related">
	<h3><?php __('Related Srnas');?></h3>
	<?php if (!empty($type['Srna'])):?>
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
	</tr>
	<?php
		$i = 0;
		foreach ($type['Srna'] as $srna):
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
		</tr>
	<?php endforeach; ?>
	</table>
<?php endif; ?>
</div>
