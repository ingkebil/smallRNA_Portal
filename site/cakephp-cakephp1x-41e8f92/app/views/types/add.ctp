<div class="types form">
<?php echo $this->Form->create('Type');?>
	<fieldset>
 		<legend><?php printf(__('Add %s', true), __('Type', true)); ?></legend>
	<?php
		echo $this->Form->input('name');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>

		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Types', true)), array('action' => 'index'));?></li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Snras', true)), array('controller' => 'snras', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Snra', true)), array('controller' => 'snras', 'action' => 'add')); ?> </li>
	</ul>
</div>