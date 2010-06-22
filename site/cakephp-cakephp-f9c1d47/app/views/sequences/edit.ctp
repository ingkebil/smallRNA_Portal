<div class="sequences form">
<?php echo $this->Form->create('Sequence');?>
	<fieldset>
 		<legend><?php __('Edit Sequence'); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('seq');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>

		<li><?php echo $this->Html->link(__('Delete', true), array('action' => 'delete', $this->Form->value('Sequence.id')), null, sprintf(__('Are you sure you want to delete # %s?', true), $this->Form->value('Sequence.id'))); ?></li>
		<li><?php echo $this->Html->link(__('List Sequences', true), array('action' => 'index'));?></li>
		<li><?php echo $this->Html->link(__('List Srnas', true), array('controller' => 'srnas', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Srna', true), array('controller' => 'srnas', 'action' => 'add')); ?> </li>
	</ul>
</div>