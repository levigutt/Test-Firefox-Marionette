#!/usr/bin/env perl -wl
use strict;
use Test::Firefox::Marionette;
use File::Basename;
use Cwd;

my $base = sprintf 'file://%s/t/data/', getcwd();
my $ff = Test::Firefox::Marionette->new();

my @html_files = map basename($_), glob('t/data/*.html');
$ff->go_ok($base . $_) for @html_files;

$ff->done_testing();
