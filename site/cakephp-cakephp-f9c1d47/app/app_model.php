<?php
/**
 * Application model for Cake.
 *
 * This file is application-wide model file. You can put all
 * application-wide model-related methods here.
 *
 * PHP versions 4 and 5
 *
 * CakePHP(tm) : Rapid Development Framework (http://cakephp.org)
 * Copyright 2005-2010, Cake Software Foundation, Inc. (http://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright 2005-2010, Cake Software Foundation, Inc. (http://cakefoundation.org)
 * @link          http://cakephp.org CakePHP(tm) Project
 * @package       cake
 * @subpackage    cake.app
 * @since         CakePHP(tm) v 0.2.9
 * @license       MIT License (http://www.opensource.org/licenses/mit-license.php)
 */

/**
 * Application model for Cake.
 *
 * Add your application-wide methods in the class below, your models
 * will inherit them.
 *
 * @package       cake
 * @subpackage    cake.app
 */
class AppModel extends Model {

    var $additionalFields = array();

    function findInformationSchema($table = null) {
        $db =& ConnectionManager::getDataSource('default');
        $db_name = $db->config['database'];
        $q = 'SELECT *,
                  `TABLE_SCHEMA`       AS `Db`,
                  `TABLE_NAME`         AS `Name`,
                  `TABLE_TYPE`         AS `TABLE_TYPE`,
                  `ENGINE`             AS `Engine`,
                  `ENGINE`             AS `Type`,
                  `VERSION`            AS `Version`,
                  `ROW_FORMAT`         AS `Row_format`,
                  `TABLE_ROWS`         AS `Rows`,
                  `AVG_ROW_LENGTH`     AS `Avg_row_length`,
                  `DATA_LENGTH`        AS `Data_length`,
                  `MAX_DATA_LENGTH`    AS `Max_data_length`,
                  `INDEX_LENGTH`       AS `Index_length`,
                  `DATA_FREE`          AS `Data_free`,
                  `AUTO_INCREMENT`     AS `Auto_increment`,
                  `CREATE_TIME`        AS `Create_time`,
                  `UPDATE_TIME`        AS `Update_time`,
                  `CHECK_TIME`         AS `Check_time`,
                  `TABLE_COLLATION`    AS `Collation`,
                  `CHECKSUM`           AS `Checksum`,
                  `CREATE_OPTIONS`     AS `Create_options`,
                  `TABLE_COMMENT`      AS `Comment`
             FROM `information_schema`.`TABLES` AS `Schema`
             WHERE `TABLE_SCHEMA` = "' . mysql_real_escape_string($db_name) . '"';
        if ($table) {
            $q .= ' AND `Schema`.`TABLE_NAME` = "' . mysql_real_escape_string($table) . '"';
        }

        return $this->query($q);
    }

#    function paginateCount($conditions = null, $recursive = 0, $extra = array()) {
#        if (!$conditions) {
#            $schema = $this->findInformationSchema($this->useTable);
#
#            if ($schema[0]['Schema']['Engine'] == 'InnoDB') {
#                return $schema[0]['Schema']['Rows'];
#            }
#        }
#        return parent::paginateCount($conditions, $recursive, $extra);
#    }

#    function paginateCount($conditions = null, $recursive = 0, $extra = array()) {
#        $this->recursive = $recursive;
#        $rs = $this->find('all', array('conditions' => $conditions, 'fields' => $this->name . '.id'), 'contain' => false);
#        
#        return count($rs);
#    }

    /**
     * Makes the smallest possible count queryving out all joins and thus taking advantage of the indexes
     *
     */
    function paginateCount($conditions = null, $recursive = 0, $extra = array()) {
        if (isset($extra['unbindcount'])) {
            $this->recursive = -1;
        }
        if (isset($extra['countContains'])) {
            $this->contain($extra['countContains']);
        }
        $options = array('conditions' => $conditions);
        if (isset($extra['joins'])) {
            $options['joins'] = $extra['joins'];
        }

        if (isset($extra['group'])) {
        }

        return $this->find('count', $options);
    }

    function hasField($name) {
        $hf = parent::hasField($name);
        if ($hf) {
            return $hf;
        }

        return in_array($name, $this->additionalFields);
    }

}
?>
