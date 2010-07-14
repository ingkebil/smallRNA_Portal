<div class="annotations view">
<h2><?php  __('Annotation');?></h2>
	<dl><?php $i = 0; $class = ' class="altrow"';?>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Accession Nr'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $html->link($annotation['Annotation']['accession_nr'], 'http://arabidopsis.org/servlets/TairObject?type=locus&name='.$annotation['Annotation']['accession_nr']); ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Model Nr'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $annotation['Annotation']['model_nr']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Start'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $annotation['Annotation']['start']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Stop'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $annotation['Annotation']['stop']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Strand'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $annotation['Annotation']['strand']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Chr'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $annotation['Chromosome']['name']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Type'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $annotation['Annotation']['type']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Species'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $this->Html->link($annotation['Species']['full_name'], array('controller' => 'species', 'action' => 'view', $annotation['Species']['id'])); ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Sequence'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<textarea><?php echo $annotation['Annotation']['seq']; ?></textarea>
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Comment'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $annotation['Annotation']['comment']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Source'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $this->Html->link($annotation['Source']['name'], array('controller' => 'sources', 'action' => 'view', $annotation['Source']['id'])); ?>
			&nbsp;
		</dd>
	</dl>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>
		<li><?php echo $this->Html->link(__('Edit Annotation', true), array('action' => 'edit', $annotation['Annotation']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('Delete Annotation', true), array('action' => 'delete', $annotation['Annotation']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $annotation['Annotation']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('List Annotations', true), array('action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Annotation', true), array('action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Species', true), array('controller' => 'species', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Species', true), array('controller' => 'species', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Sources', true), array('controller' => 'sources', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Source', true), array('controller' => 'sources', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Structures', true), array('controller' => 'structures', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Structure', true), array('controller' => 'structures', 'action' => 'add')); ?> </li>
	</ul>
</div>
<div class="related">
	<h3><?php __('Related Structures');?></h3>
	<?php if (!empty($annotation['Structure'])):?>
	<table cellpadding = "0" cellspacing = "0">
	<tr>
		<!--th><?php __('Id'); ?></th>
		<th><?php __('Annotation Id'); ?></th-->
		<th><?php __('Start'); ?></th>
		<th><?php __('Stop'); ?></th>
		<th><?php __('Utr'); ?></th>
		<!--th class="actions"><?php __('Actions');?></th-->
	</tr>
	<?php
		$i = 0;
		foreach ($annotation['Structure'] as $structure):
			$class = null;
			if ($i++ % 2 == 0) {
				$class = ' class="altrow"';
			}
		?>
		<tr<?php echo $class;?>>
			<!--td><?php echo $structure['id'];?></td>
			<td><?php echo $structure['annotation_id'];?></td-->
			<td><?php echo $structure['start'];?></td>
			<td><?php echo $structure['stop'];?></td>
			<td><?php echo $structure['utr'];?></td>
			<!--td class="actions">
				<?php $this->Html->link(__('View', true), array('controller' => 'structures', 'action' => 'view', $structure['id'])); ?>
				<?php $this->Html->link(__('Edit', true), array('controller' => 'structures', 'action' => 'edit', $structure['id'])); ?>
				<?php $this->Html->link(__('Delete', true), array('controller' => 'structures', 'action' => 'delete', $structure['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $structure['id'])); ?>
			</td-->
		</tr>
	<?php endforeach; ?>
	</table>
<?php endif; ?>

	<div class="actions">
		<ul>
			<li><?php echo $this->Html->link(__('New Structure', true), array('controller' => 'structures', 'action' => 'add'));?> </li>
		</ul>
	</div>
</div>
<h3>Related small RNAs</h3>
<?php echo $this->Jquery->page('../srnas/between', compact('srnas'), array('url' => array('controller' => 'srnas', 'action' => 'between', $annotation['Annotation']['start'], $annotation['Annotation']['stop']))); ?>
