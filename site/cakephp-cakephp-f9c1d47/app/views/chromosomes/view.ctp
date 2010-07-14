<div class="chromosomes view">
<h2><?php  __('Chromosome');?></h2>
	<dl><?php $i = 0; $class = ' class="altrow"';?>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Id'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $chromosome['Chromosome']['id']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Name'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $chromosome['Chromosome']['name']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Length'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $chromosome['Chromosome']['length']; ?>
			&nbsp;
		</dd>
	</dl>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>
		<li><?php echo $this->Html->link(__('Edit Chromosome', true), array('action' => 'edit', $chromosome['Chromosome']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('Delete Chromosome', true), array('action' => 'delete', $chromosome['Chromosome']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $chromosome['Chromosome']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('List Chromosomes', true), array('action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Chromosome', true), array('action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Annotations', true), array('controller' => 'annotations', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Annotation', true), array('controller' => 'annotations', 'action' => 'add')); ?> </li>
	</ul>
</div>
<?php echo $this->Jquery->page('../species/annotations', compact('annotations'), array('url' => array('controller' => 'chromosomes', 'action' => 'annotations' , $chromosome['Chromosome']['id']))); ?>
