<div class="species view">
<h2><?php  __('Species');?></h2>
	<dl><?php $i = 0; $class = ' class="altrow"';?>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Full Name'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
            <?php echo $html->link($species['Species']['full_name'], 'http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=' . $species['Species']['NCBI_tax_id']); ?>
			&nbsp;
		</dd>
	</dl>
</div>
<?php echo $this->Jquery->page('../species/annotations', compact('annotations'), array('url' => array('controller' => 'species', 'action' => 'annotations' , $species['Species']['id']))); ?>
<div class="related">
	<h3><?php __('Related Experiments');?></h3>
	<?php if (!empty($species['Experiment'])):?>
	<table cellpadding = "0" cellspacing = "0">
	<tr>
		<th><?php __('Name'); ?></th>
		<th><?php __('Description'); ?></th>
	</tr>
	<?php
		$i = 0;
		foreach ($species['Experiment'] as $experiment):
			$class = null;
			if ($i++ % 2 == 0) {
				$class = ' class="altrow"';
			}
		?>
		<tr<?php echo $class;?>>
			<td><?php echo $this->Html->link($experiment['name'], array('controller' => 'experiments', 'action' => 'view', $experiment['id']));?></td>
			<td><?php echo $experiment['description'];?></td>
		</tr>
	<?php endforeach; ?>
	</table>
<?php endif; ?>
</div>
