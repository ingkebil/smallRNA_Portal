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
