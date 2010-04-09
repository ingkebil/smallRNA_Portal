<div class="structures form">
<?php echo $this->Form->create('Structure');?>
	<fieldset>
 		<legend><?php printf(__('Add %s', true), __('Structure', true)); ?></legend>
	<?php
		echo $this->Form->input('annotation_id');
		echo $this->Form->input('start');
		echo $this->Form->input('stop');
		echo $this->Form->input('utr');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>

		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Structures', true)), array('action' => 'index'));?></li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Annotations', true)), array('controller' => 'annotations', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Annotation', true)), array('controller' => 'annotations', 'action' => 'add')); ?> </li>
	</ul>
</div>