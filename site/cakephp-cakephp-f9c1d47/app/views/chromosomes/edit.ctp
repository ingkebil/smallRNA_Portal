<div class="chromosomes form">
<?php echo $this->Form->create('Chromosome');?>
	<fieldset>
 		<legend><?php __('Edit Chromosome'); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('name');
		echo $this->Form->input('length');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>

		<li><?php echo $this->Html->link(__('Delete', true), array('action' => 'delete', $this->Form->value('Chromosome.id')), null, sprintf(__('Are you sure you want to delete # %s?', true), $this->Form->value('Chromosome.id'))); ?></li>
		<li><?php echo $this->Html->link(__('List Chromosomes', true), array('action' => 'index'));?></li>
		<li><?php echo $this->Html->link(__('List Annotations', true), array('controller' => 'annotations', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Annotation', true), array('controller' => 'annotations', 'action' => 'add')); ?> </li>
	</ul>
</div>