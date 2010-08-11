<div class="chromosomes view">
<h2><?php  __('Chromosome');?></h2>
	<dl><?php $i = 0; $class = ' class="altrow"';?>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Id'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $chromosome['Chromosome']['id']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Name'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $chromosome['Chromosome']['name']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Length'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $chromosome['Chromosome']['length']; ?>
			&nbsp;
		</dd>
	</dl>
</div>
<?php echo $this->Jquery->page('../species/annotations', compact('annotations'), array('url' => array('controller' => 'chromosomes', 'action' => 'annotations' , $chromosome['Chromosome']['id']))); ?>
