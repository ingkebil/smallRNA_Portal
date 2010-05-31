<div class="types form">
<?php echo $this->Form->create('Type');?>
	<fieldset>
 		<legend><?php printf(__('Edit %s', true), __('Type', true)); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('name');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>

		<li><?php echo $this->Html->link(__('Delete', true), array('action' => 'delete', $this->Form->value('Type.id')), null, sprintf(__('Are you sure you want to delete # %s?', true), $this->Form->value('Type.id'))); ?></li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Types', true)), array('action' => 'index'));?></li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Snras', true)), array('controller' => 'snras', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Snra', true)), array('controller' => 'snras', 'action' => 'add')); ?> </li>
	</ul>
</div>