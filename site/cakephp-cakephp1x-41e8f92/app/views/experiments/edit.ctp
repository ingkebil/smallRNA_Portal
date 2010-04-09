<div class="experiments form">
<?php echo $this->Form->create('Experiment');?>
	<fieldset>
 		<legend><?php printf(__('Edit %s', true), __('Experiment', true)); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('name');
		echo $this->Form->input('description');
		echo $this->Form->input('species_id');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>

		<li><?php echo $this->Html->link(__('Delete', true), array('action' => 'delete', $this->Form->value('Experiment.id')), null, sprintf(__('Are you sure you want to delete # %s?', true), $this->Form->value('Experiment.id'))); ?></li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Experiments', true)), array('action' => 'index'));?></li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Species', true)), array('controller' => 'species', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Species', true)), array('controller' => 'species', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Snras', true)), array('controller' => 'snras', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Snra', true)), array('controller' => 'snras', 'action' => 'add')); ?> </li>
	</ul>
</div>