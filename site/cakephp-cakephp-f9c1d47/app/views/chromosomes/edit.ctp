<div class="chromosomes form">
<?php echo $this->Form->create('Chromosome');?>
	<fieldset>
 		<legend><?php __('Edit Chromosome'); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('name');
		echo $this->Form->input('length');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit', true));?>
</div>
