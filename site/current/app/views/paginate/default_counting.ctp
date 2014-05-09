<p><?php
$this->Paginator->options(array(
    'update' => "#$update_id",
    'url' => $paging_url
)); 
echo $this->Paginator->counter(array(
    'format' => __('Page %page% of %pages%, showing %current% records out of %count% total, starting on record %start%, ending on %end%', true)
));
?></p>

<div class="paging">
	<?php echo $this->Paginator->prev('<< ' . __('previous', true), array(), null, array('class'=>'disabled'));?>
 | 	<?php echo $this->Paginator->numbers();?>
 |
		<?php echo $this->Paginator->next(__('next', true) . ' >>', array(), null, array('class' => 'disabled'));?>
</div>
<?php echo $this->Js->writeBuffer(); ?>
	<?php echo $this->element('sql_dump'); ?>
