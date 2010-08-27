<div class="mappings form">
<?php echo $this->Form->create('Mapping');?>
	<fieldset>
 		<legend><?php __('Edit Mapping'); ?></legend>
	<?php
		echo $this->Form->input('annotation_id');
		echo $this->Form->input('srna_id');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>

		<li><?php echo $this->Html->link(__('Delete', true), array('action' => 'delete', $this->Form->value('Mapping.id')), null, sprintf(__('Are you sure you want to delete # %s?', true), $this->Form->value('Mapping.id'))); ?></li>
		<li><?php echo $this->Html->link(__('List Mappings', true), array('action' => 'index'));?></li>
		<li><?php echo $this->Html->link(__('List Annotations', true), array('controller' => 'annotations', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Annotation', true), array('controller' => 'annotations', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Srnas', true), array('controller' => 'srnas', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Srna', true), array('controller' => 'srnas', 'action' => 'add')); ?> </li>
	</ul>
</div>