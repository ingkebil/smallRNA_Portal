<div class="species form">
<?php echo $this->Form->create('Species');?>
	<fieldset>
 		<legend><?php __('Edit Species'); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('full_name');
		echo $this->Form->input('NCBI_tax_id');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
