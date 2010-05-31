<div class="sequences form">
<?php echo $this->Form->create('Sequence');?>
	<fieldset>
 		<legend><?php printf(__('Edit %s', true), __('Sequence', true)); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('seq');
		echo $this->Form->input('seq_hash');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>

		<li><?php echo $this->Html->link(__('Delete', true), array('action' => 'delete', $this->Form->value('Sequence.id')), null, sprintf(__('Are you sure you want to delete # %s?', true), $this->Form->value('Sequence.id'))); ?></li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Sequences', true)), array('action' => 'index'));?></li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Snras', true)), array('controller' => 'snras', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Snra', true)), array('controller' => 'snras', 'action' => 'add')); ?> </li>
	</ul>
</div>