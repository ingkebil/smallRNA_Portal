<div class="srnas form">
<?php echo $this->Form->create('Srna');?>
	<fieldset>
 		<legend><?php __('Add Srna'); ?></legend>
	<?php
		echo $this->Form->input('name');
		echo $this->Form->input('start');
		echo $this->Form->input('stop');
		echo $this->Form->input('strand');
		echo $this->Form->input('sequence_id');
		echo $this->Form->input('score');
		echo $this->Form->input('type_id');
		echo $this->Form->input('abundance');
		echo $this->Form->input('normalized_abundance');
		echo $this->Form->input('experiment_id');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>

		<li><?php echo $this->Html->link(__('List Srnas', true), array('action' => 'index'));?></li>
		<li><?php echo $this->Html->link(__('List Sequences', true), array('controller' => 'sequences', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Sequence', true), array('controller' => 'sequences', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Types', true), array('controller' => 'types', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Type', true), array('controller' => 'types', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Experiments', true), array('controller' => 'experiments', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Experiment', true), array('controller' => 'experiments', 'action' => 'add')); ?> </li>
	</ul>
</div>
