<?php header('Content-Type: application/x-java-jnlp-file'); ?>
<?php echo '<?xml version="1.0" encoding="utf-8"?>'; ?>
<jnlp spec="1.0+"
  codebase="http://downloads.sourceforge.net/project/genomeview/webstart/"
>

<information>
  <title>GenomeView</title>
  <vendor>Thomas Abeel</vendor>
  <homepage href="http://genomeview.sf.net" />
  <icon href="http://broadinstitute.org/software/genomeview/gv2.png" width="47" height="47"  />
   <description>GenomeView: Genome Browser and Curator</description>
</information>
<security>
  <all-permissions />
</security>
<resources>
  <j2se version="1.6+" java-vm-args="-ea" initial-heap-size="128M" max-heap-size="1000M"/>
  <j2se version="1.6+" />
  <jar href="http://downloads.sourceforge.net/project/genomeview/webstart/genomeview-922.jar" />
  <jar href="http://downloads.sourceforge.net/project/genomeview/webstart/jannot-892.jar" />
  <jar href="http://downloads.sourceforge.net/project/genomeview/webstart/jargs.jar" />
  <jar href="http://downloads.sourceforge.net/project/genomeview/webstart/commons-logging.jar" />
  <jar href="http://downloads.sourceforge.net/project/genomeview/webstart/sam-938.jar" />
  <jar href="http://downloads.sourceforge.net/project/genomeview/webstart/ajt-2.2.jar" />
  <jar href="http://downloads.sourceforge.net/project/genomeview/webstart/collections-1.0.jar" />
</resources>
<application-desc main-class="net.sf.genomeview.gui.GenomeView">
<argument>http://gent<?php echo $html->url('/annotations/view/limit:10000/'.$annotation['Annotation']['id'].'.gff'); ?></argument></application-desc>


</jnlp>
