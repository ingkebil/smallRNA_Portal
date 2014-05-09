<?php echo $this->element('../srnas/_results'); ?>
<br />
<?php 
        $params = array(); 
        foreach ($this->params['named'] as $key => $value) {
            $params[] = urlencode($key) . ':' . urlencode($value);
        }
        $params = implode('/', $params);
    
        $stats = array('experiment', 'chromosome', 'type');
        foreach ($stats as $stat): ?>
            <div id="<?php echo $stat; ?>-stats" style="border: 1px solid #eee"><?php echo $html->image('ajax-loader.gif'); ?><span class="disabled">Getting statistics for <?php echo $stat ?>s ...</span></div>
            <?php echo $this->Html->scriptBlock($this->Js->request(array('action' => 'stats', $stat, $params), array('async' => true, 'update' => "#$stat-stats")));
        endforeach; ?>
