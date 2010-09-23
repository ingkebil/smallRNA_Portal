<div class="srnas form">
<?php echo $this->Form->create('Srna');?>
	<fieldset>
 		<legend><?php __('Search'); ?></legend>
        <table><tr><td><?php echo $this->Form->input('Annotation.accession_nr', array('empty' => true, 'label' => 'accession nr')); ?></td><td><?php echo $this->Form->input('name', array('empty' => true, 'label' => 'smallRNA name')); ?></td></tr></table>
        <table><tr><td><?php echo $this->Form->input('chromosome_id', array('empty' => true)); ?></td>
		<td><?php echo $this->Form->input('strand', array('type' => 'select', 'options' => array('+', '-'), 'empty' => true)); ?></td>
		<td><?php echo $this->Form->input('type_id', array('empty' => true)); ?></td>
		<td><?php echo $this->Form->input('experiment_id', array('empty' => true)); ?></td></tr></table>
        <table><tr>
        <td style="width:60%">
        <?php echo $this->Form->input('start', array('label' => 'Coordinates between', 'empty' => true, 'class' => 'short_input', 'div' => array('style' => 'display:inline'))); ?>
        <?php echo $this->Form->input('stop', array('label' => false, 'empty' => true, 'class' => 'short_input', 'div' => array('style' => 'display:inline'))); ?>
        </td>
        <td>
        <?php echo $this->Form->input('normalized_abundance_between', array('class' => 'short_input', 'div' => array('style' => 'display:inline'))); ?>
        <?php echo $this->Form->input('normalized_abundance_stop', array('label' => false, 'class' => 'short_input', 'div' => array('style' => 'display:inline'))); ?>
        </td>
        </tr></table>
		<?php echo $this->Form->input('Sequence.seq', array('label' => 'Sequence contains')); ?>
	</fieldset>
<?php echo $this->Form->end(__('Search', true));?>
</div>
