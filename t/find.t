#!/usr/bin/env perl -wl
use strict;
use Test::Firefox::Marionette;
use Cwd;

my $base = sprintf 'file://%s/t/data/', getcwd();
my $ff = Test::Firefox::Marionette->new();

$ff->go_ok($base . 'elements.html');
$ff->ok(!$ff->has_tag('custom-square'), 'Square not present at start');
$ff->find_class_ok('add')->click();
$ff->find_ok('//custom-square');
$ff->find_tag_ok('custom-square');
$ff->find_link_ok('My Link');
$ff->find_partial_ok('Link');
$ff->find_class_ok('remove')->click();
$ff->ok(!$ff->has_tag('custom-square'), 'Square was removed');

$ff->go_ok($base . 'form.html');
$ff->find_id_ok('username');
$ff->find_name_ok('phone');
$ff->find_selector_ok('input[type=checkbox]');

$ff->done_testing();

