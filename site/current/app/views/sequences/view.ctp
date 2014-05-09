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
<div class="related">
	<h3><?php __('Related Srnas');?></h3>
<?php echo $this->Jquery->page('../srnas/between', compact('srnas'), array('url' => array('controller' => 'sequences', 'action' => 'srna', $sequence['Sequence']['id']))); ?>
</div>
