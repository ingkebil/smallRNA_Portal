<?php

class AppController extends Controller {

    var $uses = array('Experiment', 'Species', 'Types');
    var $helpers = array('Jquery', 'Session', 'Cache');
    var $cacheAction = '1 hour';

    function beforeFilter() {
        $this->RequestHandler->__requestContent['gff'] = 'text/plain';
        $this->RequestHandler->__requestContent['jnlp'] = 'application/x-java-jnlp-file';
    }

    function beforeRender() {
        parent::beforeRender();

        $this->call_generate_menu();
    }

    function call_generate_menu() {
        if ( ! file_exists(CACHE . 'menu.array')) {
            $menu = $this->Species->find_species_types_exps();
            file_put_contents(CACHE . 'menu.array', serialize($menu));
        }
        else {
            $menu = unserialize(file_get_contents(CACHE . 'menu.array'));
        }

        $this->set('site_menu', $menu);
    }


    function paginate_only($object = null, $scope = array(), $whitelist = array(), $normalCount = 0) {
        $options = array();
        if (!isset($this->params['named']['only'])) {
            $options['only'] = 'page'; # only give us the first page, not the pagination itself
        }

        $model_name = '';
        if (is_object($object)) {
            $model_name = $object->name;
        } elseif (is_string($object)) {
            $model_name = $object;
        }

        $model_name = ucfirst($model_name);

        if (is_array($this->paginate)) {
            if (array_key_exists($model_name, $this->paginate)) {
                $this->paginate[$model_name] = array_merge($this->paginate[$model_name], $options);
            }
            else {
                $this->paginate = array_merge($this->paginate, $options);
            }
        }

        return $this->paginate($object, $scope, $whitelist, $normalCount);
    }

/**
 * Handles automatic pagination of model records.
 * Added the skipping of the actual paginating query when the count is zero.
 * Normal counting behaviour binds with all models, evenif the where doesn't require this. Normal behaviour is now that no models are bound. You can toggle back to original bheviour with the added 4th param.
 *
 * @param mixed $object Model to paginate (e.g: model instance, or 'Model', or 'Model.InnerModel')
 * @param mixed $scope Conditions to use while paginating
 * @param array $whitelist List of allowed options for paging
 * @return array Model query results
 * @access public
 * @link http://book.cakephp.org/view/1232/Controller-Setup
 */
	function paginate($object = null, $scope = array(), $whitelist = array(), $normalCount = 0) {
		if (is_array($object)) {
			$whitelist = $scope;
			$scope = $object;
			$object = null;
		}
		$assoc = null;

		if (is_string($object)) {
			$assoc = null;
			if (strpos($object, '.')  !== false) {
				list($object, $assoc) = pluginSplit($object);
			}

			if ($assoc && isset($this->{$object}->{$assoc})) {
				$object =& $this->{$object}->{$assoc};
			} elseif (
				$assoc && isset($this->{$this->modelClass}) &&
				isset($this->{$this->modelClass}->{$assoc}
			)) {
				$object =& $this->{$this->modelClass}->{$assoc};
			} elseif (isset($this->{$object})) {
				$object =& $this->{$object};
			} elseif (
				isset($this->{$this->modelClass}) && isset($this->{$this->modelClass}->{$object}
			)) {
				$object =& $this->{$this->modelClass}->{$object};
			}
		} elseif (empty($object) || $object === null) {
			if (isset($this->{$this->modelClass})) {
				$object =& $this->{$this->modelClass};
			} else {
				$className = null;
				$name = $this->uses[0];
				if (strpos($this->uses[0], '.') !== false) {
					list($name, $className) = explode('.', $this->uses[0]);
				}
				if ($className) {
					$object =& $this->{$className};
				} else {
					$object =& $this->{$name};
				}
			}
		}

		if (!is_object($object)) {
			trigger_error(sprintf(
				__('Controller::paginate() - can\'t find model %1$s in controller %2$sController',
					true
				), $object, $this->name
			), E_USER_WARNING);
			return array();
		}
		$options = array_merge($this->params, $this->params['url'], $this->passedArgs);

		if (isset($this->paginate[$object->alias])) {
			$defaults = $this->paginate[$object->alias];
		} else {
			$defaults = $this->paginate;
		}

		if (isset($options['show'])) {
			$options['limit'] = $options['show'];
		}

		if (isset($options['sort'])) {
			$direction = null;
			if (isset($options['direction'])) {
				$direction = strtolower($options['direction']);
			}
			if ($direction != 'asc' && $direction != 'desc') {
				$direction = 'asc';
			}
			$options['order'] = array($options['sort'] => $direction);
		}

		if (!empty($options['order']) && is_array($options['order'])) {
			$alias = $object->alias ;
			$key = $field = key($options['order']);

			if (strpos($key, '.') !== false) {
				list($alias, $field) = explode('.', $key);
			}
			$value = $options['order'][$key];
			unset($options['order'][$key]);

			if ($object->hasField($field)) {
				$options['order'][$alias . '.' . $field] = $value;
			} elseif ($object->hasField($field, true)) {
				$options['order'][$field] = $value;
			} elseif (isset($object->{$alias}) && $object->{$alias}->hasField($field)) {
				$options['order'][$alias . '.' . $field] = $value;
			}
		}
		$vars = array('fields', 'order', 'limit', 'page', 'recursive', 'only', 'update');
		$keys = array_keys($options);
		$count = count($keys);

		for ($i = 0; $i < $count; $i++) {
			if (!in_array($keys[$i], $vars, true)) {
				unset($options[$keys[$i]]);
			}
			if (empty($whitelist) && ($keys[$i] === 'fields' || $keys[$i] === 'recursive')) {
				unset($options[$keys[$i]]);
			} elseif (!empty($whitelist) && !in_array($keys[$i], $whitelist)) {
				unset($options[$keys[$i]]);
			}
		}
		$conditions = $fields = $order = $limit = $page = $recursive = null;
        
		if (!isset($defaults['conditions'])) {
			$defaults['conditions'] = array();
		}

		$type = 'all';

		if (isset($defaults[0])) {
			$type = $defaults[0];
			unset($defaults[0]);
		}

		$options = array_merge(array('page' => 1, 'limit' => 20), $defaults, $options);
		$options['limit'] = (int) $options['limit'];
		if (empty($options['limit']) || $options['limit'] < 1) {
			$options['limit'] = 1;
		}

		extract($options);

		if (is_array($scope) && !empty($scope)) {
			$conditions = array_merge($conditions, $scope);
		} elseif (is_string($scope)) {
			$conditions = array($conditions, $scope);
		}
		if ($recursive === null) {
			$recursive = $object->recursive;
		}

		$extra = array_diff_key($defaults, compact(
			'conditions', 'fields', 'order', 'limit', 'page', 'recursive'
		));
        $more_extras = array('only', 'update');
        foreach ($more_extras as $e) {
            if (isset($options[$e])) {
                $extra[$e] = $options[$e];
            }
        }
		if ($type !== 'all') {
			$extra['type'] = $type;
		}

        if (!isset($extra['only']) || $extra['only'] == 'count') {
            $recursiveCount = $recursive;
            if (!$normalCount) {
                $recursiveCount = -1;
            }
            if (method_exists($object, 'paginateCount')) {
                $count = $object->paginateCount($conditions, $recursiveCount, $extra);
            } else {
                $parameters = compact('conditions');
                if ($recursiveCount != $object->recursive) {
                    $parameters['recursive'] = $recursive;
                }
                $count = $object->find('count', array_merge($parameters, $extra));
            }
            $pageCount = intval(ceil($count / $limit));

        }
        else {
            $pageCount = 0;
        }

		if (isset($extra['only']) && $extra['only'] == 'count' && ($page === 'last' || $page >= $pageCount)) {
			$options['page'] = $page = $pageCount;
		} elseif (intval($page) < 1) {
			$options['page'] = $page = 1;
		}
		$page = $options['page'] = (integer)$page;

        if ($count !== 0 || (isset($extra['only']) && $extra['only'] == 'page')) {
            if (method_exists($object, 'paginate')) {
                $results = $object->paginate(
                    $conditions, $fields, $order, $limit, $page, $recursive, $extra
                );
            } else {
                $parameters = compact('conditions', 'fields', 'order', 'limit', 'page');
                if ($recursive != $object->recursive) {
                    $parameters['recursive'] = $recursive;
                }
                $results = $object->find($type, array_merge($parameters, $extra));
            }
        }
        else {
            $results = array();
        }
		$paging = array(
			'page'		=> $page,
			'current'	=> count($results),
			'count'		=> $count,
			'prevPage'	=> ($page > 1),
			'nextPage'	=> ($count > ($page * $limit)),
			'pageCount'	=> $pageCount,
			'defaults'	=> array_merge(array('limit' => 20, 'step' => 1), $defaults),
			'options'	=> $options
		);
		$this->params['paging'][$object->alias] = $paging;

		if (!in_array('Paginator', $this->helpers) && !array_key_exists('Paginator', $this->helpers)) {
			$this->helpers[] = 'Paginator';
		}

        # decide on what to render
        if (isset($extra['only'])) {
            if ($extra['only'] == 'count') { # rendering only the pagination navigation links 
                # remove the only 'param' from the url somehow
                $url =  $this->params;
                # remove some unwanted things for the creation of the new url
                unset($url['named']['only']);
                unset($url['named']['update']);
                unset($url['url']['ext']);

                # remove those things that we don't want to have merged back into the paging urls
                unset($this->params['paging'][$object->alias]['options']['only']);
                unset($this->params['paging'][$object->alias]['options']['update']);

                #$paging_url = array_intersect_key(array('controller', 'action'), $url);
                $url['named']['only'] = 'page'; # make sure that the links of the paging only do a page link
                #$url = array_merge($paging_url, $url['named']);
                $url = '/'.implode('/', array_slice(explode('/', Router::reverse($url)), 4)); # I don't understand why I need to cut off the controller/action part here :/
                $this->set('paging_url', $url);
                $this->set('update_id', $extra['update']);

                $view_paths = App::path('views');
                if (file_exists($view_paths[0] . $this->name . '/_' . $this->params['action'] . '_counting.ctp')) {
                    $this->renderAction('_'.$this->params['action'].'_counting');
                }
                else {
                    $this->renderAction('../paginate/default_counting');
                }
            }
        }

		return $results;
	}

    function renderAction($action = null) {
        if (!is_null($action)) {
            $this->action = $action;
        }

        return $this->action;
    }

}
?>
