<?php
	#
	# By Cal Henderson <cal@iamcal.com>
	# This code is licensed under a Creative Commons Attribution-ShareAlike 2.5 License
	# http://creativecommons.org/licenses/by-sa/2.5/
	#

	$dir = dirname(__FILE__);
	include($dir.'/wrapper.php');


	plan(2);

	filter_harness("<img src='\"onerror=\"alert()'>", "<img src=\"&quot;onerror=&quot;alert()\" />");

	filter_harness(
		"<img alt='src=\"src=0 width=0 onerror=alert(unescape(/dang%20quotes!/.source))//'>",
		"<img src=\"0\" width=\"0\" alt=\"src=&quot;src=0 width=0 onerror=alert(unescape(/dang%20quotes!/.source))//\" />");
