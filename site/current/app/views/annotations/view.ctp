<?php $this->Html->script('raphael-min', array('inline' => false, 'once' => true)); ?>
<?php //$this->Html->script('raphael.zoom', array('inline' => false, 'once' => true)); ?>
<?php //$this->Html->script('genestruct', array('inline' => false, 'once' => true)); ?>
<?php $this->Html->script('divstruct', array('inline' => false, 'once' => true)); ?>
<?php $this->Html->script('jquery-1.4.2.min', array('inline' => false, 'once' => true)); ?>
<?php $this->Html->script('jquery-ui', array('inline' => false, 'once' => true)); ?>
<?php //$this->Html->script('SVGPan', array('inline' => false, 'once' => true)); ?>
<div class="annotations view">
<h2><?php  __('Annotation');?></h2>
    <div style="float: right;">
        <?php echo $html->link('View in GenomeView', '/annotations/view/limit:100000/'.$annotation['Annotation']['id'].'.jnlp', array('style' => '-moz-border-radius:8px 8px 8px 8px; background:-moz-linear-gradient(center top , #F1F1D4, #E6E49F) repeat scroll 0 0 #E6E49F; border:1px solid #AAAC62; color:#333333; font-weight:normal; min-width:0; padding:4px 8px; text-decoration:none; text-shadow:0 1px 0 #FFFFFF;')); ?><br /><br />
<?php echo $html->link('Download as GFF', '/annotations/view/limit:100000/'.$annotation['Annotation']['id'].'.gff', array('style' => '-moz-border-radius:8px 8px 8px 8px; background:-moz-linear-gradient(center top , #F1F1D4, #E6E49F) repeat scroll 0 0 #E6E49F; border:1px solid #AAAC62; color:#333333; font-weight:normal; min-width:0; padding:4px 8px; text-decoration:none; text-shadow:0 1px 0 #FFFFFF;')); ?>
    </div>
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
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Reads'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $srna_red_read_count[0][0]['abundance_count']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Normalized reads'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $srna_red_read_count[0][0]['norm_abundance_count']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Non-redundant Reads'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $this->params['paging']['Mapping']['count']; ?>
			&nbsp;
		</dd>
	</dl>
</div>
<div class="related">
<h3>Gene structure </h3>
	<?php
        $struct = '';
        $start = -1;
        $stop = -1;
		foreach ($annotation['Structure'] as $structure):
            $start = $start == -1 ? $structure['start'] : $start;
            $stop  = $structure['stop' ];
            $struct .= ';' . $structure['start'] . $structure['utr'] . $structure['stop'];
	    endforeach; ?>
	</table>
    <?php 
        $srna_coords = array();
        foreach ($all_srnas as $srna) {
            $srna_coords[] = "['".$srna['Srna']['start']."','".$srna['Srna']['stop']."','".$srna['Srna']['id']."']";
        }
        $degr_coords = array();
        foreach ($all_degr as $srna) {
            $degr_coords[] = "['".$srna['Srna']['start']."','".$srna['Srna']['stop']."','".$srna['Srna']['id']."']";
        }
    ?>
    <div>Current zoom level: <span id="zoomlevel">1</span></div>
    <div style="overflow: hidden; border: 1px dotted grey; height: <?php echo count($all_srnas) + count($all_degr) + 60; ?>px;"><div id="genestruct" style="height: <?php echo count($all_srnas) + count($all_degr) + 60; ?>px; position: relative;">&nbsp;</div></div>
    <?php substr($struct, 1); echo $this->Html->scriptBlock("
        var srnas = [ ".implode(',', $srna_coords)." ];
        var degrs = [ ".implode(',', $degr_coords)." ];
        drawstructs('genestruct', '$struct', srnas, degrs, $start, $stop);
        $(document).ready(function () {
        //    $(window).resize(function () {
        //        drawstructs('genestruct', '$struct', srnas, degrs, $start, $stop);
        //    });
            $('#genestruct').draggable({ axis: 'x' });
        //    //SVGPanInit(document.getElementById('genestruct').firstChild);
        });
    "); ?>
</div>
<h3>Related small RNAs <span><?php echo $html->link('Download as GFF', '/annotations/srnas/limit:100000/'.$annotation['Annotation']['id'].'.gff', array('style' => '-moz-border-radius:8px 8px 8px 8px; background:-moz-linear-gradient(center top , #F1F1D4, #E6E49F) repeat scroll 0 0 #E6E49F; border:1px solid #AAAC62; color:#333333; font-weight:normal; min-width:0; padding:4px 8px; text-decoration:none; text-shadow:0 1px 0 #FFFFFF;')); ?></span></h3>
<?php echo $this->Jquery->lazy_page('../annotations/srnas', compact('srnas'), array('url' => array('controller' => 'annotations', 'action' => 'srnas', $annotation['Annotation']['id']))); ?>
