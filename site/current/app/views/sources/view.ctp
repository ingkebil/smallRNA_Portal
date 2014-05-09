<div class="sources view">
<h2><?php  __('Source');?></h2>
	<dl><?php $i = 0; $class = ' class="altrow"';?>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Name'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $source['Source']['name']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Description'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $source['Source']['description']; ?>
			&nbsp;
		</dd>
	</dl>
</div>
<h3>Related Annotations</h3>
<?php echo $this->Jquery->page('../annotations/between', compact('annotations'), array('url' => array('controller' => 'annotations', 'action' => 'source', $source['Source']['id']))); ?>
