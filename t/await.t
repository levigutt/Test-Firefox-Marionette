#!/usr/bin/env perl -wl
use strict;
use Test::Firefox::Marionette;
use Cwd;

my $ff = Test::Firefox::Marionette->new();

my $file = sprintf 'file://%s/t/data/elements.html', getcwd();
$ff->go_ok($file);

$ff->await_ok( sub { $ff->ok(1, "Callback was called") } );

$ff->done_testing();
