<html>  
<head>  
    <meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>  
    <title>AnnoJ smallRNA</title>

    <!-- ExtJS Dependencies -->  
    <?php echo $html->css('/annoj/css/ext-all.css'); ?>
    <!-- link type='text/css' rel='stylesheet' href='http://www.annoj.org/css/ext-all.css' /-->  
    <!-- <script type='text/javascript' src='http://www.annoj.org/js/ext-base.js'></script> --> 
    <!-- <script type='text/javascript' src='http://www.annoj.org/js/ext-all.js'></script> -->
    <?php echo $javascript->link("/annoj/js/ext-base.js"); ?> 
    <?php echo $javascript->link("/annoj/js/ext-all.js"); ?>

    <!-- CSS -->  
    <?php echo $html->css('/annoj/css/viewport.css'); ?>
    <?php echo $html->css('/annoj/css/plugins.css'); ?>

    <!--link type='text/css' rel='stylesheet' href='http://www.annoj.org/css/viewport.css' /-->  
    <!--link type='text/css' rel='stylesheet' href='http://www.annoj.org/css/plugins.css' /--> 
    <?php echo $html->css('/annoj/css/beg_style.css'); ?>

    <!-- Config -->  
    <!--script type='text/javascript' src='http://www.annoj.org/js/aj-min4.js'></script-->  
    <?php echo $javascript->link('/annoj/js/aj-min4-full.js'); ?>

<!-- Config -->  
<?php if (empty($contig)): ?>
<?php echo $javascript->link("/annoj/js/$genome.conf.js"); ?>
<?php else: ?>
<script type="text/javascript" src="<?php echo $html->url("/annoj/link/$genome/$contig/$position/$bases");?>"></script>
<?php endif; ?>
</head>  

<body>  
<!-- Message for people who do not have JS enabled -->  
<noscript>  
<table id='noscript'><tr>  
<td><?php echo $html->image("/annoj/css/img/Anno-J.jpg"); ?></td> 
<td>  
<p>Anno-J cannot run because your browser is currently configured to block JavaScript.</p>  
<p>To use the application please access your browser settings or preferences, turn JavaScript support back on, and then refresh this page.</p>  
<p>Thank you, and enjoy the application!</p>  
</td>  
</tr></table>  
</noscript>  
</body>  

</html>  
