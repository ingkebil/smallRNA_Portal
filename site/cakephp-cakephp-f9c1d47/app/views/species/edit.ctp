<div class="species form">
<?php echo $this->Form->create('Species');?>
	<fieldset>
 		<legend><?php printf(__('Edit %s', true), __('Species', true)); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('full_name');
		echo $this->Form->input('NCBI_tax_id');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>

		<li><?php echo $this->Html->link(__('Delete', true), array('action' => 'delete', $this->Form->value('Species.id')), null, sprintf(__('Are you sure you want to delete # %s?', true), $this->Form->value('Species.id'))); ?></li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Species', true)), array('action' => 'index'));?></li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Annotations', true)), array('controller' => 'annotations', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Annotation', true)), array('controller' => 'annotations', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Experiments', true)), array('controller' => 'experiments', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Experiment', true)), array('controller' => 'experiments', 'action' => 'add')); ?> </li>
	</ul>
</div>