<div class="experiments form">
<?php echo $this->Form->create('Experiment');?>
	<fieldset>
 		<legend><?php __('Edit Experiment'); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('name');
		echo $this->Form->input('description');
		echo $this->Form->input('species_id');
		echo $this->Form->input('internal');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
