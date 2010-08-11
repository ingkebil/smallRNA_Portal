<div class="sequences form">
<?php echo $this->Form->create('Sequence');?>
	<fieldset>
 		<legend><?php __('Edit Sequence'); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('seq');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
