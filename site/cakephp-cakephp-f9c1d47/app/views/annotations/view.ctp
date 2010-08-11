<div class="annotations view">
<h2><?php  __('Annotation');?></h2>
	<dl><?php $i = 0; $class = ' class="altrow"';?>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Accession Nr'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $html->link($annotation['Annotation']['accession_nr'], 'http://arabidopsis.org/servlets/TairObject?type=locus&name='.$annotation['Annotation']['accession_nr']); ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Model Nr'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $annotation['Annotation']['model_nr']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Start'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $annotation['Annotation']['start']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Stop'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $annotation['Annotation']['stop']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Strand'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $annotation['Annotation']['strand']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Chr'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $annotation['Chromosome']['name']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Type'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $annotation['Annotation']['type']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Species'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $this->Html->link($annotation['Species']['full_name'], array('controller' => 'species', 'action' => 'view', $annotation['Species']['id'])); ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Sequence'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<textarea><?php echo $annotation['Annotation']['seq']; ?></textarea>
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Comment'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $annotation['Annotation']['comment']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Source'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $this->Html->link($annotation['Source']['name'], array('controller' => 'sources', 'action' => 'view', $annotation['Source']['id'])); ?>
			&nbsp;
		</dd>
	</dl>
</div>
<div class="related">
	<h3><?php __('Related Structures');?></h3>
	<?php if (!empty($annotation['Structure'])):?>
	<table cellpadding = "0" cellspacing = "0">
	<tr>
		<th><?php __('Start'); ?></th>
		<th><?php __('Stop'); ?></th>
		<th><?php __('Utr'); ?></th>
	</tr>
	<?php
		$i = 0;
		foreach ($annotation['Structure'] as $structure):
			$class = null;
			if ($i++ % 2 == 0) {
				$class = ' class="altrow"';
			}
		?>
		<tr<?php echo $class;?>>
			<td><?php echo $structure['start'];?></td>
			<td><?php echo $structure['stop'];?></td>
			<td><?php echo $structure['utr'];?></td>
		</tr>
	<?php endforeach; ?>
	</table>
<?php endif; ?>
</div>
<h3>Related small RNAs</h3>
<?php echo $this->Jquery->page('../srnas/between', compact('srnas'), array('url' => array('controller' => 'srnas', 'action' => 'between', $annotation['Annotation']['start'], $annotation['Annotation']['stop']))); ?>
