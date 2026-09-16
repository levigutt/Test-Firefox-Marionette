#!/usr/bin/env perl -wl
use strict;
use List::Util qw<all>;
use Test::Firefox::Marionette;
use Test::Simple tests => 2;
use Cwd;

my $ff = Test::Firefox::Marionette->new();
$ff->go(sprintf('file://%s/t/data/form.html', getcwd()));

my %fields = (  username => 'japh'
             ,  email    => 'japhy@example.com'
             ,  address  => '56 japhstreet'
             ,  phone    => '000-555-123123'
             ,  agree    => 'on'
             ,  gender   => 'm'
             ,  comment  => 'yet another submission'
             );
my $form = $ff->find_tag('form');
$ff->submit_form_ok($form, \%fields, "Could submit the form");

my $uri = $ff->uri();
ok all( sub { $uri->query_param($_) eq $fields{$_} }, keys %fields ),
    "All fields are in query params";
