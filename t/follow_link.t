#!/usr/bin/env perl -wl
use strict;
use Test::Firefox::Marionette;
use Cwd;

my $base = sprintf 'file://%s/t/data/', getcwd();
my $ff = Test::Firefox::Marionette->new();

$ff->go($base . 'elements.html');
$ff->follow_link_ok(sub { $_->text =~ /go to form/     }, "Could follow link to form");
$ff->follow_link_ok(sub { $_->text =~ /go to elements/ }, "Could follow link to elements");

$ff->done_testing();
