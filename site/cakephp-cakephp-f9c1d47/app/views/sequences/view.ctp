<div class="sequences view">
<h2><?php  __('Sequence');?></h2>
	<dl><?php $i = 0; $class = ' class="altrow"';?>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Seq'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $sequence['Sequence']['seq']; ?>
			&nbsp;
		</dd>
	</dl>
</div>
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>
		<li><?php echo $this->Html->link(__('Edit Sequence', true), array('action' => 'edit', $sequence['Sequence']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('Delete Sequence', true), array('action' => 'delete', $sequence['Sequence']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $sequence['Sequence']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('List Sequences', true), array('action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Sequence', true), array('action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Srnas', true), array('controller' => 'srnas', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Srna', true), array('controller' => 'srnas', 'action' => 'add')); ?> </li>
	</ul>
</div>
<div class="related">
	<h3><?php __('Related Srnas');?></h3>
<?php echo $this->Jquery->page('../srnas/between', compact('srnas'), array('url' => array('controller' => 'sequences', 'action' => 'srna', $sequence['Sequence']['id']))); ?>
</div>
