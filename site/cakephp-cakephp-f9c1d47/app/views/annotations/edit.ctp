<div class="annotations form">
<?php echo $this->Form->create('Annotation');?>
	<fieldset>
 		<legend><?php printf(__('Edit %s', true), __('Annotation', true)); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('accession_nr');
		echo $this->Form->input('model_nr');
		echo $this->Form->input('start');
		echo $this->Form->input('stop');
		echo $this->Form->input('strand');
		echo $this->Form->input('chr');
		echo $this->Form->input('type');
		echo $this->Form->input('species_id');
		echo $this->Form->input('seq');
		echo $this->Form->input('comment');
		echo $this->Form->input('source_id');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>

		<li><?php echo $this->Html->link(__('Delete', true), array('action' => 'delete', $this->Form->value('Annotation.id')), null, sprintf(__('Are you sure you want to delete # %s?', true), $this->Form->value('Annotation.id'))); ?></li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Annotations', true)), array('action' => 'index'));?></li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Species', true)), array('controller' => 'species', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Species', true)), array('controller' => 'species', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Sources', true)), array('controller' => 'sources', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Source', true)), array('controller' => 'sources', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('List %s', true), __('Structures', true)), array('controller' => 'structures', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(sprintf(__('New %s', true), __('Structure', true)), array('controller' => 'structures', 'action' => 'add')); ?> </li>
	</ul>
</div>