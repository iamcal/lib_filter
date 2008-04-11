<?php
	#
	# lib_filter.txt
	#
	# A PHP HTML filtering library
	#
	# $Id: lib_filter.php,v 1.15 2006/09/28 22:44:31 cal Exp $
	#
	# http://iamcal.com/publish/articles/php/processing_html/
	# http://iamcal.com/publish/articles/php/processing_html_part_2/
	#
	# By Cal Henderson <cal@iamcal.com>
	# This code is licensed under a Creative Commons Attribution-ShareAlike 2.5 License
	# http://creativecommons.org/licenses/by-sa/2.5/
	#
	# Thanks to Jang Kim for adding support for single quoted attributes
	#


	$filter = new lib_filter();

	class lib_filter {

		var $tag_counts = array();

		#
		# tags and attributes that are allowed
		#

		var $allowed = array(
			'a' => array('href', 'target'),
			'b' => array(),
			'img' => array('src', 'width', 'height', 'alt'),
		);


		#
		# tags which should always be self-closing (e.g. "<img />")
		#

		var $no_close = array(
			'img',
		);


		#
		# tags which must always have seperate opening and closing tags (e.g. "<b></b>")
		#

		var $always_close = array(
			'a',
			'b',
		);


		#
		# attributes which should be checked for valid protocols
		#

		var $protocol_attributes = array(
			'src',
			'href',
		);


		#
		# protocols which are allowed
		#

		var $allowed_protocols = array(
			'http',
			'ftp',
			'mailto',
		);


		#
		# tags which should be removed if they contain no content (e.g. "<b></b>" or "<b />")
		#

		var $remove_blanks = array(
			'a',
			'b',
		);


		#
		# should we remove comments?
		#

		var $strip_comments = 1;


		#
		# should we try and make a b tag out of "b>"
		#

		var $always_make_tags = 1;


		#
		# entity control options
		#

		var $allow_numbered_entities = 1;

		var $allowed_entities = array(
			'amp',
			'gt',
			'lt',
			'quot',
		);


		###############################################################

		function go($data){

			$this->tag_counts = array();

			$data = $this->escape_comments($data);
			$data = $this->balance_html($data);
			$data = $this->check_tags($data);
			$data = $this->process_remove_blanks($data);
			$data = $this->validate_entities($data);

			return $data;
		}

		###############################################################

		function escape_comments($data){

			$data = preg_replace("/<!--(.*?)-->/se", "'<!--'.HtmlSpecialChars(\$this->StripSingle('\\1')).'-->'", $data);

			return $data;
		}

		###############################################################

		function balance_html($data){

			if ($this->always_make_tags){

				#
				# try and form html
				#

				$data = preg_replace("/>>+/", ">", $data);
				$data = preg_replace("/<<+/", "<", $data);
				$data = preg_replace("/^>/", "", $data);
				$data = preg_replace("/<([^>]*?)(?=<|$)/", "<$1>", $data);
				$data = preg_replace("/(^|>)([^<]*?)(?=>)/", "$1<$2", $data);

			}else{

				#
				# escape stray brackets
				#

				$data = preg_replace("/<([^>]*?)(?=<|$)/", "&lt;$1", $data);
				$data = preg_replace("/(^|>)([^<]*?)(?=>)/", "$1$2&gt;<", $data);

				#
				# the last regexp causes '<>' entities to appear
				# (we need to do a lookahead assertion so that the last bracket can
				# be used in the next pass of the regexp)
				#

				$data = str_replace('<>', '', $data);
			}

			#echo "::".HtmlSpecialChars($data)."<br />\n";

			return $data;
		}

		###############################################################

		function check_tags($data){

			$data = preg_replace("/<(.*?)>/se", "\$this->process_tag(\$this->StripSingle('\\1'))",	$data);

			foreach(array_keys($this->tag_counts) as $tag){
				for($i=0; $i<$this->tag_counts[$tag]; $i++){
					$data .= "</$tag>";
				}
			}

			return $data;
		}

		###############################################################

		function process_tag($data){

			# ending tags
			if (preg_match("/^\/([a-z0-9]+)/si", $data, $matches)){
				$name = StrToLower($matches[1]);
				if (in_array($name, array_keys($this->allowed))){
					if (!in_array($name, $this->no_close)){
						if ($this->tag_counts[$name]){
							$this->tag_counts[$name]--;
							return '</'.$name.'>';
						}
					}
				}else{
					return '';
				}
			}

			# starting tags
			if (preg_match("/^([a-z0-9]+)(.*?)(\/?)$/si", $data, $matches)){

				$name = StrToLower($matches[1]);
				$body = $matches[2];
				$ending = $matches[3];
				if (in_array($name, array_keys($this->allowed))){
					$params = "";
					preg_match_all("/([a-z0-9]+)=([\"'])(.*?)\\2/si", $body, $matches_2, PREG_SET_ORDER);		# <foo a="b" />
					preg_match_all("/([a-z0-9]+)(=)([^\"\s']+)/si", $body, $matches_1, PREG_SET_ORDER);		# <foo a=b />
					preg_match_all("/([a-z0-9]+)=([\"'])([^\"']*?)\s*$/si", $body, $matches_3, PREG_SET_ORDER);	# <foo a="b />
					$matches = array_merge($matches_1, $matches_2, $matches_3);

					foreach($matches as $match){
						$pname = StrToLower($match[1]);
						if (in_array($pname, $this->allowed[$name])){
							$value = $match[3];
							if (in_array($pname, $this->protocol_attributes)){
								$value = $this->process_param_protocol($value);
							}
							$params .= " $pname=\"$value\"";
						}
					}
					if (in_array($name, $this->no_close)){
						$ending = ' /';
					}
					if (in_array($name, $this->always_close)){
						$ending = '';
					}
					if (!$ending){
						if (isset($this->tag_counts[$name])){
							$this->tag_counts[$name]++;
						}else{
							$this->tag_counts[$name] = 1;
						}
					}
					if ($ending){
						$ending = ' /';
					}
					return '<'.$name.$params.$ending.'>';
				}else{
					return '';
				}
			}

			# comments
			if (preg_match("/^!--(.*)--$/si", $data)){
				if ($this->strip_comments){
					return '';
				}else{
					return '<'.$data.'>';
				}
			}


			# garbage, ignore it
			return '';
		}

		###############################################################

		function process_param_protocol($data){

			$data = $this->decode_entities($data);

			if (preg_match("/^([^:]+)\:/si", $data, $matches)){
				if (!in_array($matches[1], $this->allowed_protocols)){
					$data = '#'.substr($data, strlen($matches[1])+1);
				}
			}

			return $data;
		}

		###############################################################

		function process_remove_blanks($data){
			foreach($this->remove_blanks as $tag){

				$data = preg_replace("/<{$tag}(\s[^>]*)?><\\/{$tag}>/", '', $data);
				$data = preg_replace("/<{$tag}(\s[^>]*)?\\/>/", '', $data);
			}
			return $data;
		}

		###############################################################

		function fix_case($data){

			$data_notags = Strip_Tags($data);
			$data_notags = preg_replace('/[^a-zA-Z]/', '', $data_notags);

			if (strlen($data_notags)<5){
				return $data;
			}

			if (preg_match('/[a-z]/', $data_notags)){
				return $data;
			}

			return preg_replace(
				"/(>|^)([^<]+?)(<|$)/se",
					"\$this->StripSingle('\\1').".
					"\$this->fix_case_inner(\$this->StripSingle('\\2')).".
					"\$this->StripSingle('\\3')",
				$data
			);
		}

		function fix_case_inner($data){

			$data = StrToLower($data);

			$data = preg_replace(
				'/(^|[^\w\s\';,\\-])(\s*)([a-z])/e',
				"\$this->StripSingle('\\1\\2').StrToUpper(\$this->StripSingle('\\3'))",
				$data
			);

			return $data;
		}

		###############################################################

		function validate_entities($data){

			# validate entities throughout the string

			$data = preg_replace(
				'!&([^&;]*)(?=(;|&|$))!e',
				"\$this->check_entity(\$this->StripSingle('\\1'), \$this->StripSingle('\\2'))",
				$data
			);


			# validate quotes outside of tags 

			$data = preg_replace(
				"/(>|^)([^<]+?)(<|$)/se",
					"\$this->StripSingle('\\1').".
					"str_replace('\"', '&quot;', \$this->StripSingle('\\2')).".
					"\$this->StripSingle('\\3')",
				$data
			);

			return $data;
		}

		function check_entity($preamble, $term){

			if ($term != ';'){

				return '&amp;'.$preamble;
			}

			if ($this->is_valid_entity($preamble)){

				return '&'.$preamble;
			}

			return '&amp;'.$preamble;
		}

		function is_valid_entity($entity){

			if (preg_match('!^#([0-9]+)$!i', $entity, $m)){

				if ($m[1] > 127){
					return 1;
				}

				return $this->allow_numbered_entities;
			}

			if (in_array($entity, $this->allowed_entities)){

				return 1;
			}

			return 0;
		}

		###############################################################

		#
		# within attributes, we want to convert all hex/dec/url escape sequences into
		# their raw characters so that we can check we don't get stray quotes/brackets
		# inside strings
		#

		function decode_entities($data){

			$data = preg_replace_callback('!(&)#(\d+);?!', array($this, 'decode_dec_entity'), $data);
			$data = preg_replace_callback('!(&)#x([0-9a-f]+);?!i', array($this, 'decode_hex_entity'), $data);
			$data = preg_replace_callback('!(%)([0-9a-f]{2});?!i', array($this, 'decode_hex_entity'), $data);

			$data = $this->validate_entities($data);

			return $data;
		}

		function decode_hex_entity($m){

			return $this->decode_num_entity($m[1], hexdec($m[2]));
		}

		function decode_dec_entity($m){

			return $this->decode_num_entity($m[1], intval($m[2]));
		}

		function decode_num_entity($orig_type, $d){

			if ($d < 0){ $d = 32; } # space

			# don't mess with huigh chars
			if ($d > 127){
				if ($orig_type == '%'){ return '%'.dechex($d); }
				if ($orig_type == '&'){ return "&#$d;"; }
			}

			return HtmlSpecialChars(chr($d));
		}

		###############################################################

		function StripSingle($data){
			return str_replace(array('\\"', "\\0"), array('"', chr(0)), $data);
		}

		###############################################################

	}

?>