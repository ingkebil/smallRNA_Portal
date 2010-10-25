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
        <!--?php echo $html->link('View in GenomeView', '/annotations/view/limit:100000/'.$annotation['Annotation']['id'].'.jnlp', array('style' => '-moz-border-radius:8px 8px 8px 8px; background:-moz-linear-gradient(center top , #F1F1D4, #E6E49F) repeat scroll 0 0 #E6E49F; border:1px solid #AAAC62; color:#333333; font-weight:normal; min-width:0; padding:4px 8px; text-decoration:none; text-shadow:0 1px 0 #FFFFFF;')); ?><br /><br /-->
<!--?php echo $html->link('Download as GFF', '/annotations/view/limit:100000/'.$annotation['Annotation']['id'].'.gff', array('style' => '-moz-border-radius:8px 8px 8px 8px; background:-moz-linear-gradient(center top , #F1F1D4, #E6E49F) repeat scroll 0 0 #E6E49F; border:1px solid #AAAC62; color:#333333; font-weight:normal; min-width:0; padding:4px 8px; text-decoration:none; text-shadow:0 1px 0 #FFFFFF;')); ?-->
    </div>
	<dl><?php $i = 0; $class = ' class="altrow"';?>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Sequence'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<textarea><?php echo $options['Sequence']; ?></textarea>
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Command'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo $result['Command']; ?>
			&nbsp;
		</dd>
		<dt<?php if ($i % 2 == 0) echo $class;?>><?php __('Count'); ?></dt>
		<dd<?php if ($i++ % 2 == 0) echo $class;?>>
			<?php echo count($result['Hit']); ?>
			&nbsp;
		</dd>
	</dl>
</div>
<div class="related">
<h3>Gene structure </h3>
	<?php
        $start = 1;
        $stop  = strlen($options['Sequence']);
        $struct = ';1N' . $stop;
    ?>
	</table>
    <?php 
        $srna_coords = array();
        $srna_count = 0;
        #foreach ($result['Hit'] as $srna) {
        #    $srna_count++;
        #    $srna_coords[] = "['".$srna['Srna']['start']."','".$srna['Srna']['stop']."','".$srna['Srna']['id']."']";
        #}
        #$degr_coords = array();
        #foreach ($all_degr as $srna) {
        #    $srna_count++;
        #    $degr_coords[] = "['".$srna['Srna']['start']."','".$srna['Srna']['stop']."','".$srna['Srna']['id']."']";
        #}
        #foreach ($result['Hit'] as $srnas) {
        #    foreach($srnas['Srna'] as $srna) {
        #        $srna_count++;
        #        $srna_coords[] = "['".$srna['start']."','".$srna['stop']."','".$srna['id']."']";
        #    }
        #}
        $srna_coords = array();
        foreach ($all_srnas as $srna) {
            $srna_count++;
            $srna_coords[] = "['".$srna['Srna']['start']."','".$srna['Srna']['stop']."','".$srna['Srna']['id']."']";
        }
        $degr_coords = array();
        foreach ($all_degrs as $srna) {
            $srna_count++;
            $degr_coords[] = "['".$srna['Srna']['start']."','".$srna['Srna']['stop']."','".$srna['Srna']['id']."']";
        }
    ?>
    <div>Current zoom level: <span id="zoomlevel">1</span></div>
    <div style="overflow: hidden; border: 1px dotted grey; height: <?php echo $srna_count + 60; ?>px;"><div id="genestruct" style="height: <?php echo $srna_count + 60; ?>px; position: relative;">&nbsp;</div></div>
    <?php substr($struct, 1); echo $this->Html->scriptBlock("
        var srnas = [ ".implode(',', $srna_coords)." ];
        var degrs = [ ".implode(',', $degr_coords)."];
        drawstructs('genestruct', '$struct', srnas, degrs, $start, $stop);
        $(document).ready(function () {
            $('#genestruct').draggable({ axis: 'x' });
        });
    "); ?>
</div>
<?php echo $this->Jquery->lazy_page('../srnas/blastedsrnas', compact('srnas'), array('url' => array('controller' => 'srnas', 'action' => 'blastedsrnas'))); ?>
