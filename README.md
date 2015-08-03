lib_filter
==========

[![Build Status](https://secure.travis-ci.org/iamcal/lib_filter.png)](http://travis-ci.org/iamcal/lib_filter)

A PHP HTML-input-filtering library.
You can read about how it works in 
<a href="http://www.iamcal.com/publish/articles/php/processing_html/">this article</a>
(<a href="http://www.iamcal.com/publish/articles/php/processing_html_part_2/">part 2</a>).

## Usage

This library can be used to filter HTML directly entered by users, or recieved via a richtext editor.
The library ensures that no harmful HTML will be output into the browser, avoiding all forms of XSS attacks.

    include('lib_filter.php');

    $filter = new lib_filter();

    $safe_html = $filter->go($user_input);

    echo $safe_html;

## Legacy

This library has been used in many projects and frameworks, ported to other languages and 
used as the basis for other filtering libraries. For instance:

* Symfony plugin: https://github.com/studioskylab/skValidatorHTMLPlugin


## Testing

If you have perl's <a href="http://search.cpan.org/dist/Test-Harness/">Test::Harness</a> installed (you almost certainly do), you can 
run the tests using:

    make test
 
When submitting patches or pull-requests, bonus points are given for adding test cases.
