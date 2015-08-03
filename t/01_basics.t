<?php
	#
	# By Cal Henderson <cal@iamcal.com> 
	# This code is licensed under a Creative Commons Attribution-ShareAlike 2.5 License
	# http://creativecommons.org/licenses/by-sa/2.5/
	#

	$dir = dirname(__FILE__);
	include($dir.'/wrapper.php');


	plan(227);

	# basics
	filter_harness("","");
	filter_harness("hello","hello");

	# balancing tags
	filter_harness("<b>hello","<b>hello</b>");
	filter_harness("hello<b>","hello");
	filter_harness("hello<b>world","hello<b>world</b>");
	filter_harness("hello</b>","hello");
	filter_harness("hello<b/>","hello");
	filter_harness("hello<b/>world","hello<b>world</b>");
	filter_harness("<b><b><b>hello","<b><b><b>hello</b></b></b>");
	filter_harness("</b><b>","");

	# end slashes
	filter_harness('<img>','<img />');
	filter_harness('<img/>','<img />');
	filter_harness('<b/></b>','');

	# balancing angle brakets

	$filter->always_make_tags = 1;
	filter_harness('<img src="foo"','<img src="foo" />');
	filter_harness('b>','');
	filter_harness('b>hello','<b>hello</b>');
	filter_harness('<img src="foo"/','<img src="foo" />');
	filter_harness('>','');
	filter_harness('hello<b','hello');
	filter_harness('b>foo','<b>foo</b>');
	filter_harness('><b','');
	filter_harness('b><','');
	filter_harness('><b>','');
	filter_harness('foo bar>','');
	filter_harness('foo>bar>baz','baz');
	filter_harness('foo>bar','bar');
	filter_harness('foo>bar>','');
	filter_harness('>foo>bar','bar');
	filter_harness('>foo>bar>','');

	$filter->always_make_tags = 0;
	filter_harness('<img src="foo"','&lt;img src=&quot;foo&quot;');
	filter_harness('b>','b&gt;');
	filter_harness('b>hello','b&gt;hello');
	filter_harness('<img src="foo"/','&lt;img src=&quot;foo&quot;/');
	filter_harness('>','&gt;');
	filter_harness('hello<b','hello&lt;b');
	filter_harness('b>foo','b&gt;foo');
	filter_harness('><b','&gt;&lt;b');
	filter_harness('b><','b&gt;&lt;');
	filter_harness('><b>','&gt;');
	filter_harness('foo bar>','foo bar&gt;');
	filter_harness('foo>bar>baz','foo&gt;bar&gt;baz');
	filter_harness('foo>bar','foo&gt;bar');
	filter_harness('foo>bar>','foo&gt;bar&gt;');
	filter_harness('>foo>bar','&gt;foo&gt;bar');
	filter_harness('>foo>bar>','&gt;foo&gt;bar&gt;');


	# attributes
	filter_harness('<img src=foo>','<img src="foo" />');
	filter_harness('<img asrc=foo>','<img />');
	filter_harness('<img src=test test>','<img src="test" />');

	# non-allowed tags
	filter_harness('<script>','');
	filter_harness('<script/>','');
	filter_harness('</script>','');
	filter_harness('<script woo=yay>','');
	filter_harness('<script woo="yay">','');
	filter_harness('<script woo="yay>','');

	$filter->always_make_tags = 1;
	filter_harness('<script','');
	filter_harness('<script woo="yay<b>','');
	filter_harness('<script woo="yay<b>hello','<b>hello</b>');
	filter_harness('<script<script>>','');
	filter_harness('<<script>script<script>>','script');
	filter_harness('<<script><script>>','');
	filter_harness('<<script>script>>','');
	filter_harness('<<script<script>>','');

	$filter->always_make_tags = 0;
	filter_harness('<script','&lt;script');
	filter_harness('<script woo="yay<b>','&lt;script woo=&quot;yay');
	filter_harness('<script woo="yay<b>hello','&lt;script woo=&quot;yay<b>hello</b>');
	filter_harness('<script<script>>','&lt;script&gt;');
	filter_harness('<<script>script<script>>','&lt;script&gt;');
	filter_harness('<<script><script>>','&lt;&gt;');
	filter_harness('<<script>script>>','&lt;script&gt;&gt;');
	filter_harness('<<script<script>>','&lt;&lt;script&gt;');


	# bad protocols
	filter_harness('<a href="http://foo">bar</a>', '<a href="http://foo">bar</a>');
	filter_harness('<a href="ftp://foo">bar</a>', '<a href="ftp://foo">bar</a>');
	filter_harness('<a href="mailto:foo">bar</a>', '<a href="mailto:foo">bar</a>');
	filter_harness('<a href="javascript:foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="java script:foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="java'."\t".'script:foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="java'."\n".'script:foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="java'."\r".'script:foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="java'.chr(1).'script:foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="java'.chr(0).'script:foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="jscript:foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="vbscript:foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="view-source:foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="  javascript:foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="jAvAsCrIpT:foo">bar</a>', '<a href="#foo">bar</a>');

	# bad protocols with entities (semicolons)
	filter_harness('<a href="&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="&#0000106;&#0000097;&#0000118;&#0000097;&#0000115;&#0000099;&#0000114;&#0000105;&#0000112;&#0000116;&#0000058;foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="&#x6A;&#x61;&#x76;&#x61;&#x73;&#x63;&#x72;&#x69;&#x70;&#x74;&#x3A;foo">bar</a>', '<a href="#foo">bar</a>');

	# bad protocols with entities (no semicolons)
	filter_harness('<a href="&#106&#97&#118&#97&#115&#99&#114&#105&#112&#116&#58;foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="&#0000106&#0000097&#0000118&#0000097&#0000115&#0000099&#0000114&#0000105&#0000112&#0000116&#0000058foo">bar</a>', '<a href="#foo">bar</a>');
	filter_harness('<a href="&#x6A&#x61&#x76&#x61&#x73&#x63&#x72&#x69&#x70&#x74&#x3A;foo">bar</a>', '<a href="#foo">bar</a>');

	# self-closing tags
	filter_harness('<img src="a">', '<img src="a" />');
	filter_harness('<img src="a">foo</img>', '<img src="a" />foo');
	filter_harness('</img>', '');

	# typos
	filter_harness('<b>test<b/>', '<b>test</b>');
	filter_harness('<b/>test<b/>', '<b>test</b>');
	filter_harness('<b/>test', '<b>test</b>');

	# empty tags
	filter_harness('woo<b></b>', 'woo');
	filter_harness('<b></b>woo<b></b>', 'woo');
	filter_harness('<b></b>woo<a></a>', 'woo');
	filter_harness('woo<a/>', 'woo');
	filter_harness('woo<a/><b></b>', 'woo');
	filter_harness('woo<a><b></b></a>', 'woo');

	# case conversion
	case_harness('hello world', 'hello world');
	case_harness('Hello world', 'Hello world');
	case_harness('Hello World', 'Hello World');
	case_harness('HELLO World', 'HELLO World');
	case_harness('HELLO WORLD', 'Hello world');
	case_harness('<b>HELLO WORLD', '<b>Hello world');
	case_harness('<B>HELLO WORLD', '<B>Hello world');
	case_harness('HELLO. WORLD', 'Hello. World');
	case_harness('HELLO<b> WORLD', 'Hello<b> World');
	case_harness("DOESN'T", "Doesn't");
	case_harness("COMMA, TEST", 'Comma, test');
	case_harness("SEMICOLON; TEST", 'Semicolon; test');
	case_harness("DASH - TEST", 'Dash - test');

	# comments
	$filter->strip_comments = 0;
	filter_harness('hello <!-- foo --> world', 'hello <!-- foo --> world');
	filter_harness('hello <!-- <foo --> world', 'hello <!-- &lt;foo --> world');
	filter_harness('hello <!-- foo> --> world', 'hello <!-- foo&gt; --> world');
	filter_harness('hello <!-- <foo> --> world', 'hello <!-- &lt;foo&gt; --> world');

	$filter->strip_comments = 1;
	filter_harness('hello <!-- foo --> world', 'hello  world');
	filter_harness('hello <!-- <foo --> world', 'hello  world');
	filter_harness('hello <!-- foo> --> world', 'hello  world');
	filter_harness('hello <!-- <foo> --> world', 'hello  world');

	# br - shouldn't get caught by the empty 'b' tag remover
	$filter->allowed['br'] = array();
	$filter->no_close[] = 'br';
	filter_harness('foo<br>bar', 'foo<br />bar');
	filter_harness('foo<br />bar', 'foo<br />bar');

	# stray quotes
	filter_harness('foo"bar', 'foo&quot;bar');
	filter_harness('foo"', 'foo&quot;');
	filter_harness('"bar', '&quot;bar');
	filter_harness('<a href="foo"bar">baz</a>', '<a href="foo">baz</a>');
	filter_harness('<a href=foo"bar>baz</a>', '<a href="foo">baz</a>');

	# correct entities should not be touched
	filter_harness('foo&amp;bar', 'foo&amp;bar');
	filter_harness('foo&quot;bar', 'foo&quot;bar');
	filter_harness('foo&lt;bar', 'foo&lt;bar');
	filter_harness('foo&gt;bar', 'foo&gt;bar');

	# bare ampersands should be fixed up
	filter_harness('foo&bar', 'foo&amp;bar');
	filter_harness('foo&', 'foo&amp;');

	# numbered entities
	$filter->allow_numbered_entities = 1;
	filter_harness('foo&#123;bar', 'foo&#123;bar');
	filter_harness('&#123;bar', '&#123;bar');
	filter_harness('foo&#123;', 'foo&#123;');

	$filter->allow_numbered_entities = 0;
	filter_harness('foo&#123;bar', 'foo&amp;#123;bar');
	filter_harness('&#123;bar', '&amp;#123;bar');
	filter_harness('foo&#123;', 'foo&amp;#123;');

	# other entities
	filter_harness('foo&bar;baz', 'foo&amp;bar;baz');	
	$filter->allowed_entities[] = 'bar';
	filter_harness('foo&bar;baz', 'foo&bar;baz');

	# entity decoder - '<'
	$entities = explode(' ', "%3c %3C &#60 &#0000060 &#60; &#0000060; &#x3c &#x000003c &#x3c; &#x000003c; &#X3c &#X000003c &#X3c; &#X000003c; &#x3C &#x000003C &#x3C; &#x000003C; &#X3C &#X000003C &#X3C; &#X000003C;");
	foreach($entities as $entity){
		 entity_harness($entity, '&lt;');
	}

	entity_harness('%3c&#256;&#x100;', '&lt;&#256;&#256;');
	entity_harness('%3c&#250;&#xFA;', '&lt;&#250;&#250;');
	entity_harness('%3c%40%aa;', '&lt;@%aa');


	# character checks
	filter_harness('\\', '\\');
	filter_harness('/', '/');
	filter_harness("'", "'");
	filter_harness('a'.chr(0).'b', 'a'.chr(0).'b');
	filter_harness('\\/\'!@#', '\\/\'!@#');
	filter_harness('$foo', '$foo');

	# this test doesn't contain &"<> since they get changed
	$all_chars = ' !#$%\'()*+,-./0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~';
	filter_harness($all_chars, $all_chars);

	# single quoted entities
	filter_harness("<img src=foo.jpg />", '<img src="foo.jpg" />');
	filter_harness("<img src='foo.jpg' />", '<img src="foo.jpg" />');
	filter_harness("<img src=\"foo.jpg\" />", '<img src="foo.jpg" />');

	# unbalanced quoted entities
	filter_harness("<img src=\"foo.jpg />", '<img src="foo.jpg" />');
	filter_harness("<img src='foo.jpg />", '<img src="foo.jpg" />');
	filter_harness("<img src=foo.jpg\" />", '<img src="foo.jpg" />');
	filter_harness("<img src=foo.jpg' />", '<img src="foo.jpg" />');

	# url escape sequences
	filter_harness('<a href="woo.htm%22%20bar=%22#">foo</a>', '<a href="woo.htm&quot; bar=&quot;#">foo</a>');
	filter_harness('<a href="woo.htm%22%3E%3C/a%3E%3Cscript%3E%3C/script%3E%3Ca%20href=%22#">foo</a>', '<a href="woo.htm&quot;&gt;&lt;/a&gt;&lt;script&gt;&lt;/script&gt;&lt;a href=&quot;#">foo</a>');
	filter_harness('<a href="woo.htm%aa">foo</a>', '<a href="woo.htm%aa">foo</a>');


	#
	# this set of tests shows the differences between the different
	# combinations of entity options
	#

	$filter->allow_numbered_entities = 0;
	$filter->normalise_ascii_entities = 0;

	filter_harness('&#x3b;', '&amp;#x3b;');
	filter_harness('&#x3B;', '&amp;#x3B;');
	filter_harness('&#59;', '&amp;#59;');
	filter_harness('%3B', '%3B');
	filter_harness('&#x26;', '&amp;#x26;');
	filter_harness('&#38;', '&amp;#38;');
	filter_harness('&#xcc;', '&#xcc;');
	filter_harness('<a href="http://&#x3b;>x</a>', '<a href="http://;">x</a>');
	filter_harness('<a href="http://&#x3B;>x</a>', '<a href="http://;">x</a>');
	filter_harness('<a href="http://&#59;>x</a>', '<a href="http://;">x</a>');


	$filter->allow_numbered_entities = 1;
	$filter->normalise_ascii_entities = 0;

	filter_harness('&#x3b;', '&#x3b;');
	filter_harness('&#x3B;', '&#x3B;');
	filter_harness('&#59;', '&#59;');
	filter_harness('%3B', '%3B');
	filter_harness('&#x26;', '&#x26;');
	filter_harness('&#38;', '&#38;');
	filter_harness('&#xcc;', '&#xcc;');
	filter_harness('<a href="http://&#x3b;>x</a>', '<a href="http://;">x</a>');
	filter_harness('<a href="http://&#x3B;>x</a>', '<a href="http://;">x</a>');
	filter_harness('<a href="http://&#59;>x</a>', '<a href="http://;">x</a>');


	for ($i=0; $i<=1; $i++){

		$filter->allow_numbered_entities = $i;
		$filter->normalise_ascii_entities = 1;

		filter_harness('&#x3b;', ';');
		filter_harness('&#x3B;', ';');
		filter_harness('&#59;', ';');
		filter_harness('%3B', '%3B');
		filter_harness('&#x26;', '&amp;');
		filter_harness('&#38;', '&amp;');
		filter_harness('&#xcc;', '&#204;');
		filter_harness('<a href="http://&#x3b;>x</a>', '<a href="http://;">x</a>');
		filter_harness('<a href="http://&#x3B;>x</a>', '<a href="http://;">x</a>');
		filter_harness('<a href="http://&#59;>x</a>', '<a href="http://;">x</a>');
	}
