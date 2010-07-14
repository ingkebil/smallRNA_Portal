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
<div class="actions">
	<h3><?php __('Actions'); ?></h3>
	<ul>
		<li><?php echo $this->Html->link(__('Edit Species', true), array('action' => 'edit', $species['Species']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('Delete Species', true), array('action' => 'delete', $species['Species']['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $species['Species']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('List Species', true), array('action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Species', true), array('action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Annotations', true), array('controller' => 'annotations', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Annotation', true), array('controller' => 'annotations', 'action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Experiments', true), array('controller' => 'experiments', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Experiment', true), array('controller' => 'experiments', 'action' => 'add')); ?> </li>
	</ul>
</div>
<?php echo $this->Jquery->page('../species/annotations', compact('annotations'), array('url' => array('controller' => 'species', 'action' => 'annotations' , $species['Species']['id']))); ?>
<div class="related">
	<h3><?php __('Related Experiments');?></h3>
	<?php if (!empty($species['Experiment'])):?>
	<table cellpadding = "0" cellspacing = "0">
	<tr>
		<th><?php __('Name'); ?></th>
		<th><?php __('Description'); ?></th>
		<!--th class="actions"><?php __('Actions');?></th-->
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
			<!--td class="actions">
				<?php $this->Html->link(__('View', true), array('controller' => 'experiments', 'action' => 'view', $experiment['id'])); ?>
				<?php $this->Html->link(__('Edit', true), array('controller' => 'experiments', 'action' => 'edit', $experiment['id'])); ?>
				<?php $this->Html->link(__('Delete', true), array('controller' => 'experiments', 'action' => 'delete', $experiment['id']), null, sprintf(__('Are you sure you want to delete # %s?', true), $experiment['id'])); ?>
			</td-->
		</tr>
	<?php endforeach; ?>
	</table>
<?php endif; ?>

	<div class="actions">
		<ul>
			<li><?php echo $this->Html->link(__('New Experiment', true), array('controller' => 'experiments', 'action' => 'add'));?> </li>
		</ul>
	</div>
</div>
