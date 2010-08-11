<?php
/**
 * Short description for file.
 *
 * In this file, you set up routes to your controllers and their actions.
 * Routes are very important mechanism that allows you to freely connect
 * different urls to chosen controllers and their actions (functions).
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
 * @subpackage    cake.app.config
 * @since         CakePHP(tm) v 0.2.9
 * @license       MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
/**
 * Here, we are connecting '/' (base path) to controller called 'Pages',
 * its action called 'display', and we pass a param to select the view file
 * to use (in this case, /app/views/pages/home.ctp)...
 */
	Router::connect('/', array('controller' => 'pages', 'action' => 'display', 'home'));
/**
 * ...and connect the rest of 'Pages' controller's urls.
 */
#	Router::connect('/pages/*', array('controller' => 'pages', 'action' => 'display'));

# routes for the AnnoJ plugin
#Router::parseExtensions('json');
#Router::connect('/annoj/deligate/*', array('plugin' => 'annoj', 'controller' => 'genemodel', 'action' => 'deligate'));
Router::connect('/annoj/genemodels/*',   array('plugin' => 'annoj', 'controller' => 'genemodel', 'action' => 'deligate'));
Router::connect('/annoj/rnamodels/*',   array('plugin' => 'annoj', 'controller' => 'rnamodel', 'action' => 'deligate'));

Router::connect('/annoj/annoj_species/*',			 array('plugin' => 'annoj', 'controller' => 'annoj_species', 'action' => 'deligate'));
#Router::connect('/annoj/link/*',			 array('plugin' => 'annoj', 'controller' => 'link', 'action' => 'conf'));
Router::connect('/annoj/annoj_annotations/*', array('plugin' => 'annoj', 'controller' => 'annoj_genemodel', 'action' => 'deligate'));
#Router::connect('/annoj/repeats/*', array('plugin' => 'annoj', 'controller' => 'repeats', 'action' => 'deligate'));
#Router::connect('/annoj/ests/*', array('plugin' => 'annoj', 'controller' => 'ests', 'action' => 'deligate'));
#Router::connect('/annoj/tiling/*', array('plugin' => 'annoj', 'controller' => 'tiling', 'action' => 'deligate'));
#Router::connect('/annoj/smrna/*', array('plugin' => 'annoj', 'controller' => 'smrna', 'action' => 'deligate'));
#Router::connect('/annoj/rnamodel/*', array('plugin' => 'annoj', 'controller' => 'rnamodel', 'action' => 'deligate'));
#
Router::connect('/annoj/images/*',			 array('plugin' => 'annoj', 'controller' => 'images', 'action' => 'image'));
#Router::connect('/annoj/css/img/*',		 array('plugin' => 'annoj', 'controller' => 'images', 'action' => 'image'));
Router::connect('/annoj/*',			 array('plugin' => 'annoj', 'controller' => 'annoj_species', 'action' => 'index'));

?>
