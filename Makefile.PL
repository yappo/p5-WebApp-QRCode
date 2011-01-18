use inc::Module::Install;
name 'WebApp-QRCode';
all_from 'lib/WebApp/QRCode.pm';
readme_from 'lib/WebApp/QRCode.pm';
readme_markdown_from 'lib/WebApp/QRCode.pm';
githubmeta;

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
