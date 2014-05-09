<ul>
<?php foreach ($site_menu as $species_name => $species): ?>
    <li>
        <h1><?php echo $html->link($species_name, array('controller' => 'species', 'action' => 'view', $species['short_name']), array('alt' => 'View related annotations', 'title' => 'View related annotations')) ?></h1>
        <ul>
        <?php foreach ($species['srna_types'] as $type => $experiments): ?>
        <li><?php echo $type ?>
            <ul>
            <?php foreach ($experiments as $experiment): ?>
                <li><?php echo $html->link($experiment, array('controller' => 'pages', 'action' => 'display', $species['short_name'], $type, $experiment)); ?></li>
            <?php endforeach; ?>
            </ul>
        <?php endforeach; ?>
        </ul>
    </li>
<?php endforeach; ?>
</ul>
