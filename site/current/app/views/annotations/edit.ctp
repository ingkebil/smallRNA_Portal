<div class="annotations form">
<?php echo $this->Form->create('Annotation');?>
	<fieldset>
 		<legend><?php __('Edit Annotation'); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('accession_nr');
		echo $this->Form->input('model_nr');
		echo $this->Form->input('start');
		echo $this->Form->input('stop');
		echo $this->Form->input('strand');
		echo $this->Form->input('chromosome_id');
		echo $this->Form->input('type');
		echo $this->Form->input('species_id');
		echo $this->Form->input('seq');
		echo $this->Form->input('comment');
		echo $this->Form->input('source_id');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
