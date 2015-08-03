<?php
	#
	# A simple PHP test harness
	#
	# By Cal Henderson <cal@iamcal.com>
	# This code is licensed under a Creative Commons Attribution-ShareAlike 2.5 License
	# http://creativecommons.org/licenses/by-sa/2.5/
	#

	$dir = dirname(__FILE__);
	include($dir.'/testmore.php');
	include($dir.'/../lib_filter.php');


	$GLOBALS['filter'] = new lib_filter();

	function filter_harness($in, $out){
		$got = $GLOBALS['filter']->go($in);
		is($got, $out, "Filter test: ".$in);
	}

	function case_harness($in, $out){
		$got = $GLOBALS['filter']->fix_case($in);
		is($got, $out, "Case test: ".$in);
	}

	function entity_harness($in, $out){
		$got = $GLOBALS['filter']->decode_entities($in);
		is($got, $out, "Entity test: ".$in);
	}
