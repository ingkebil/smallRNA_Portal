<div class="mappings view">
<h2><?php  __('Mapping');?></h2>
	<dl><?php $i = 0; $class = ' class="altrow"';?>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Annotation'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $this->Html->link($mapping['Annotation']['id'], array('controller' => 'annotations', 'action' => 'view', $mapping['Annotation']['id'])); ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Srna'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $this->Html->link($mapping['Srna']['name'], array('controller' => 'srnas', 'action' => 'view', $mapping['Srna']['id'])); ?>
			&nbsp;
		</dd>
	</dl>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>
		<li><?php echo $this->Html->link(__('Edit Mapping', true), array('action' => 'edit', $mapping['Mapping']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('Delete Mapping', true), array('action' => 'delete', $mapping['Mapping']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $mapping['Mapping']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('List Mappings', true), array('action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Mapping', true), array('action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Annotations', true), array('controller' => 'annotations', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Annotation', true), array('controller' => 'annotations', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Srnas', true), array('controller' => 'srnas', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Srna', true), array('controller' => 'srnas', 'action' => 'add')); ?> </li>
	</ul>
</div>
