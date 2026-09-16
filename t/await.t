#!/usr/bin/env perl -wl
use strict;
use Test::Firefox::Marionette;
use Test::Simple tests => 2;
use Cwd;

my $ff = Test::Firefox::Marionette->new();

my $file = sprintf 'file://%s/t/data/elements.html', getcwd();
$ff->go($file);

$ff->await_ok( sub { ok 1, "Callback was called"} );

