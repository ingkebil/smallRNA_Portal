<div class="species view">
<h2><?php  __('Species');?></h2>
	<dl><?php $i = 0; $class = ' class="altrow"';?>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Id'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $species['Species']['id']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Full Name'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $species['Species']['full_name']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('NCBI Tax Id'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $species['Species']['NCBI_tax_id']; ?>
			&nbsp;
		</dd>
	</dl>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>
		<li><?php echo $this->Html->link(sprintf(__('Edit %s', true), __('Species', true)), array('action' => 'edit', $species['Species']['id'])); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('Delete %s', true), __('Species', true)), array('action' => 'delete', $species['Species']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $species['Species']['id'])); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Species', true)), array('action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Species', true)), array('action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Annotations', true)), array('controller' => 'annotations', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Annotation', true)), array('controller' => 'annotations', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Experiments', true)), array('controller' => 'experiments', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Experiment', true)), array('controller' => 'experiments', 'action' => 'add')); ?> </li>
	</ul>
</div>
<div class="related">
	<h3><?php printf(__('Related %s', true), __('Annotations', true));?></h3>
	<?php if (!empty($species['Annotation'])):?>
	<table cellpadding = "0" cellspacing = "0">
	<tr>
		<th><?php __('Id'); ?></th>
		<th><?php __('Accession Nr'); ?></th>
		<th><?php __('Model Nr'); ?></th>
		<th><?php __('Start'); ?></th>
		<th><?php __('Stop'); ?></th>
		<th><?php __('Strand'); ?></th>
		<th><?php __('Chr'); ?></th>
		<th><?php __('Type'); ?></th>
		<th><?php __('Species Id'); ?></th>
		<th><?php __('Seq'); ?></th>
		<th><?php __('Comment'); ?></th>
		<th><?php __('Source Id'); ?></th>
		<th class="actions"><?php __('Actions');?></th>
	</tr>
	<?php
		$i = 0;
		foreach ($species['Annotation'] as $annotation):
			$class = null;
			if ($i++ % 2 == 0) {
				$class = ' class="altrow"';
			}
		?>
		<tr<?php echo $class;?>>
			<td><?php echo $annotation['id'];?></td>
			<td><?php echo $annotation['accession_nr'];?></td>
			<td><?php echo $annotation['model_nr'];?></td>
			<td><?php echo $annotation['start'];?></td>
			<td><?php echo $annotation['stop'];?></td>
			<td><?php echo $annotation['strand'];?></td>
			<td><?php echo $annotation['chr'];?></td>
			<td><?php echo $annotation['type'];?></td>
			<td><?php echo $annotation['species_id'];?></td>
			<td><?php echo $annotation['seq'];?></td>
			<td><?php echo $annotation['comment'];?></td>
			<td><?php echo $annotation['source_id'];?></td>
			<td class="actions">
				<?php echo $this->Html->link(__('View', true), array('controller' => 'annotations', 'action' => 'view', $annotation['id'])); ?>
				<?php echo $this->Html->link(__('Edit', true), array('controller' => 'annotations', 'action' => 'edit', $annotation['id'])); ?>
				<?php echo $this->Html->link(__('Delete', true), array('controller' => 'annotations', 'action' => 'delete', $annotation['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $annotation['id'])); ?>
			</td>
		</tr>
	<?php endforeach; ?>
	</table>
<?php endif; ?>

	<div class="actions">
		<ul>
			<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Annotation', true)), array('controller' => 'annotations', 'action' => 'add'));?> </li>
		</ul>
	</div>
</div>
<div class="related">
	<h3><?php printf(__('Related %s', true), __('Experiments', true));?></h3>
	<?php if (!empty($species['Experiment'])):?>
	<table cellpadding = "0" cellspacing = "0">
	<tr>
		<th><?php __('Id'); ?></th>
		<th><?php __('Name'); ?></th>
		<th><?php __('Description'); ?></th>
		<th><?php __('Species Id'); ?></th>
		<th class="actions"><?php __('Actions');?></th>
	</tr>
	<?php
		$i = 0;
		foreach ($species['Experiment'] as $experiment):
			$class = null;
			if ($i++ % 2 == 0) {
				$class = ' class="altrow"';
			}
		?>
		<tr<?php echo $class;?>>
			<td><?php echo $experiment['id'];?></td>
			<td><?php echo $experiment['name'];?></td>
			<td><?php echo $experiment['description'];?></td>
			<td><?php echo $experiment['species_id'];?></td>
			<td class="actions">
				<?php echo $this->Html->link(__('View', true), array('controller' => 'experiments', 'action' => 'view', $experiment['id'])); ?>
				<?php echo $this->Html->link(__('Edit', true), array('controller' => 'experiments', 'action' => 'edit', $experiment['id'])); ?>
				<?php echo $this->Html->link(__('Delete', true), array('controller' => 'experiments', 'action' => 'delete', $experiment['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $experiment['id'])); ?>
			</td>
		</tr>
	<?php endforeach; ?>
	</table>
<?php endif; ?>

	<div class="actions">
		<ul>
			<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Experiment', true)), array('controller' => 'experiments', 'action' => 'add'));?> </li>
		</ul>
	</div>
</div>
