<div class="abundancies view">
<h2><?php  __('Abundancy');?></h2>
	<dl><?php $i = 0; $class = ' class="altrow"';?>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Annotation'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $this->Html->link($abundancy['Annotation']['id'], array('controller' => 'annotations', 'action' => 'view', $abundancy['Annotation']['id'])); ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Experiment'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $this->Html->link($abundancy['Experiment']['name'], array('controller' => 'experiments', 'action' => 'view', $abundancy['Experiment']['id'])); ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Normalized Abundance'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $abundancy['Abundancy']['normalized_abundance']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Abundance'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $abundancy['Abundancy']['abundance']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Count'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $abundancy['Abundancy']['count']; ?>
			&nbsp;
		</dd>
	</dl>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>
		<li><?php echo $this->Html->link(__('Edit Abundancy', true), array('action' => 'edit', $abundancy['Abundancy']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('Delete Abundancy', true), array('action' => 'delete', $abundancy['Abundancy']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $abundancy['Abundancy']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('List Abundancies', true), array('action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Abundancy', true), array('action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Annotations', true), array('controller' => 'annotations', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Annotation', true), array('controller' => 'annotations', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Experiments', true), array('controller' => 'experiments', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Experiment', true), array('controller' => 'experiments', 'action' => 'add')); ?> </li>
	</ul>
</div>
