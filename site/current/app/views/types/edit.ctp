<div class="types form">
<?php echo $this->Form->create('Type');?>
	<fieldset>
 		<legend><?php __('Edit Type'); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('name');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
