<div class="structures form">
<?php echo $this->Form->create('Structure');?>
	<fieldset>
 		<legend><?php __('Edit Structure'); ?></legend>
	<?php
		echo $this->Form->input('id');
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

		<li><?php echo $this->Html->link(__('Delete', true), array('action' => 'delete', $this->Form->value('Structure.id')), null, sprintf(__('Are you sure you want to delete # %s?', true), $this->Form->value('Structure.id'))); ?></li>
		<li><?php echo $this->Html->link(__('List Structures', true), array('action' => 'index'));?></li>
		<li><?php echo $this->Html->link(__('List Annotations', true), array('controller' => 'annotations', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Annotation', true), array('controller' => 'annotations', 'action' => 'add')); ?> </li>
	</ul>
</div>