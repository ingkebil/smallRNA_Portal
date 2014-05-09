<div class="sources form">
<?php echo $this->Form->create('Source');?>
	<fieldset>
 		<legend><?php __('Edit Source'); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('name');
		echo $this->Form->input('description');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
