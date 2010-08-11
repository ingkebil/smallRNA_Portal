<div class="srnas form">
<?php echo $this->Form->create('Srna');?>
	<fieldset>
 		<legend><?php __('Edit Srna'); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('name');
		echo $this->Form->input('start');
		echo $this->Form->input('stop');
		echo $this->Form->input('strand');
		echo $this->Form->input('sequence_id');
		echo $this->Form->input('score');
		echo $this->Form->input('type_id');
		echo $this->Form->input('abundance');
		echo $this->Form->input('nomalized_abundance');
		echo $this->Form->input('experiment_id');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
