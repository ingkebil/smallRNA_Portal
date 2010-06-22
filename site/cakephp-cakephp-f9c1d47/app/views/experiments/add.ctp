<div class="experiments form">
<?php echo $this->Form->create('Experiment');?>
	<fieldset>
 		<legend><?php __('Add Experiment'); ?></legend>
	<?php
		echo $this->Form->input('name');
		echo $this->Form->input('description');
		echo $this->Form->input('species_id');
		echo $this->Form->input('internal');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>

		<li><?php echo $this->Html->link(__('List Experiments', true), array('action' => 'index'));?></li>
		<li><?php echo $this->Html->link(__('List Species', true), array('controller' => 'species', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Species', true), array('controller' => 'species', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Srnas', true), array('controller' => 'srnas', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Srna', true), array('controller' => 'srnas', 'action' => 'add')); ?> </li>
	</ul>
</div>