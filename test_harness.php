<?php
	#
	# A simple PHP test harness
	#
	# $Id: test_harness.php,v 1.5 2005/11/30 21:36:49 cal Exp $
	#
	# By Cal Henderson <cal@iamcal.com>
	# This code is licensed under a Creative Commons Attribution-ShareAlike 2.5 License
	# http://creativecommons.org/licenses/by-sa/2.5/
	#

	$GLOBALS[tests] = array();
	$GLOBALS[verbose] = $GLOBALS[HTTP_GET_VARS][verbose];

	function test_harness($in, $out, $got, $name){

		$output = 0;

		if ($out == $got){
			$GLOBALS[test_passed]++;
			if ($GLOBALS[verbose]){
				echo "$name : ";
				echo "<span style=\"color: green;\">pass</span>";
				$output = 1;
			}
		}else{
			$GLOBALS[test_failed]++;
			echo "$name : ";
			echo "<span style=\"color: red; font-weight: bold;\">fail</span>";
			$output = 1;
		}
		if ($output){
			if ($GLOBALS[verbose] || ($out != $got)){
				echo " (<b>in:</b> ".htmlentities($in)." <b>expected:</b> ".htmlentities($out)." <b>got:</b> ".htmlentities($got).")";
			}
			echo "<br>\n";
		}
	}

	function test_summary(){

		$total = $GLOBALS[test_passed] + $GLOBALS[test_failed];
		$percent = Round(10000 * $GLOBALS[test_passed] / $total) / 100;

		echo "<br />\n";
		echo "Passed $GLOBALS[test_passed] of $total tests ($percent%)<br />\n";
	}

?>