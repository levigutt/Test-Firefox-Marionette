package Test::Firefox::Marionette;
use strict;
use warnings;
use 5.0100000;

our $VERSION = '1.70';

use Test::Builder ();
use List::Util qw<first>;
use Try::Tiny;
use Data::Printer;

use parent 'Firefox::Marionette';

my $TB = Test::Builder->new();

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self;
}

sub go_ok
{
    my ($self, $url, $desc) = @_;
    $desc //= sprintf 'could go to %s', $url;
    try
    {
        $self->go($url);
        $TB->ok(1, $desc );
    }
    catch
    {
        $TB->ok(0, $desc );
    }
}

sub find_ok
{
    my ($self, $xpath, $desc) = @_;
    $desc //= sprintf 'check if element by xpath "%s" exist', $xpath;
    unless( $self->SUPER::has($xpath) )
    {
        $TB->ok(0, $desc );
        return;
    }

    $TB->ok(1, $desc );
    return $self->SUPER::find($xpath);
}

sub find_class_ok
{
    my ($self, $class_name, $desc) = @_;
    $desc //= sprintf 'check if element with class "%s" exist', $class_name;
    unless( $self->SUPER::has_class($class_name) )
    {
        $TB->ok(0, $desc );
        return;
    }

    $TB->ok(1, $desc );
    return $self->SUPER::find_class($class_name);
}

sub find_id_ok
{
    my ($self, $id, $desc) = @_;
    $desc //= sprintf 'check if element by id "%s" exist', $id;
    unless( $self->SUPER::has_id($id) )
    {
        $TB->ok(0, $desc );
        return;
    }

    $TB->ok(1, $desc );
    return $self->SUPER::find_id($id);
}

sub find_name_ok
{
    my ($self, $name, $desc) = @_;
    $desc //= sprintf 'check if element by id "%s" exist', $name;
    unless( $self->SUPER::has_name($name) )
    {
        $TB->ok(0, $desc );
        return;
    }

    $TB->ok(1, $desc );
    return $self->SUPER::find_name($name);
}

sub find_selector_ok
{
    my ($self, $css_selector, $desc) = @_;
    $desc //= sprintf 'check if element by selector "%s" exist', $css_selector;
    unless( $self->SUPER::has_selector($css_selector) )
    {
        $TB->ok(0, $desc );
        return;
    }

    $TB->ok(1, $desc );
    return $self->SUPER::find_selector($css_selector);
}

sub find_tag_ok
{
    my ($self, $tag_name, $desc) = @_;
    $desc //= sprintf 'check if element of tag "%s" exist', $tag_name;
    unless( $self->SUPER::has_tag($tag_name) )
    {
        $TB->ok(0, $desc );
        return;
    }

    $TB->ok(1, $desc );
    return $self->SUPER::find_tag($tag_name);
}

sub find_link_ok
{
    my ($self, $text, $desc) = @_;
    $desc //= sprintf 'check if link with text "%s" exist', $text;
    unless( $self->SUPER::has_link($text) )
    {
        $TB->ok(0, $desc );
        return;
    }

    $TB->ok(1, $desc );
    return $self->SUPER::find_link($text);
}

sub find_partial_ok
{
    my ($self, $text, $desc) = @_;
    $desc //= sprintf 'check if link with partial text "%s" exist', $text;
    unless( $self->SUPER::has_partial($text) )
    {
        $TB->ok(0, $desc );
        return;
    }

    $TB->ok(1, $desc );
    return $self->SUPER::find_partial($text);
}

sub await_ok
{
    my ($self, $cb, $desc) = @_;
    $desc //= 'awaiting...';
    unless ( $self->await($cb) )
    {
        $TB->ok(0, $desc );
        return;
    }
    $TB->ok(1, $desc );
    return 1;
}

sub follow_link_ok (&;$)
{
    my $self = shift;
    my ($test_cb, $desc) = @_;

    my @links = $self->links;
    return $TB->ok(0, $desc ) unless @links;

    my $link = first { $test_cb->() } @links;
    return $TB->ok(0, $desc ) unless $link;

    try
    {
        $link->click();
        $TB->ok(1, $desc );
    }
    catch
    {
        $TB->ok(0, sprintf "%s <%s>", $desc, $_ );
    }
}

sub fill_form_ok
{
    my ($self, $form, $fields, $desc) = @_;
    for my $key (keys $fields->%*)
    {
        my $val = $fields->{$key};

        $TB->ok(0, sprintf("%s: missing field %s\n", $desc, $key) )
            unless $form->has_name($key);
        my $elem = $form->find_name($key);
        if ( grep { ($elem->attribute('type') // '') eq $_ } qw<checkbox radio> )
        {
            my $is_checked = !!($elem->attribute('checked') // 0);
            $elem->click() if  $val && !$is_checked;
            $elem->clear() if !$val &&  $is_checked;
            next;
        }
        if ( $elem->tag_name() eq 'select' )
        {
            $TB->ok(0, sprintf("%s: invalid option for %s\n", $desc, $key) )
                unless $elem->has_selector(sprintf("option[value='%s']", $val));
            my $opt = $elem->find_selector(sprintf("option[value='%s']", $val));
            $opt->click();
            next;
        }
        $elem->clear();
        $elem->type($val);
    }
    $TB->ok(1, $desc );
}

sub submit_form_ok
{
    my ($self, $form, $fields, $desc) = @_;
    $self->fill_form_ok($form, $fields, $desc);
    unless ( $form->has_selector('input[type=submit],button[type=submit]') )
    {
        $TB->ok(0, $desc );
        return;
    }
    unless ( $self->script('return arguments[0].reportValidity()', args => [ $form ]) )
    {
        $TB->ok(0, sprintf '%s (form validation failed)', $desc );
        return;
    }
    my $submit = $form->find_selector('input[type=submit],button[type=submit]');
    $submit->click();
}

sub ok
{
    my $self = shift;
    $TB->ok(@_);
}

sub done_testing
{
    $TB->done_testing();
}

## UNIMPLEMENTED

sub click_ok()
{
    ...
}

sub loaded_ok
{
    ...
}

1;
__END__

=head1 NAME

Test::Firefox::Marionette - Module to test websites with Firefox

=head1 SYNOPSIS

    use Test::Firefox::Marionette;

    my $ff = Test::Firefox::Marionette->new(visible => 1);

    $ff->go_ok('http://example.org');

    $ff->follow_link_ok( sub { $_->text =~ /Log in/ } );

    my $login_form = $ff->find_tag_ok('form');
    $ff->submit_form_ok( $login_form, { username => "admin", password => "Perl4Ever!" } );

    $ff->done_testing();

=head1 DESCRIPTION

This module is simply a wrapper around Firefox::Marionette, made because WWW::Mechanize::Firefox no longer works.

This is experimental, and the API will be in constant flux, but hopefully lands on implementing much of the same as Test::WWW::Mechanize


=head2 EXPORT

None by default.



=head1 SEE ALSO

Firefox::Marionette

WWW::Mechanize::Firefox

Test::WWW::Mechanize

=head1 AUTHOR

Levi Elias Nystad-Johansen, E<lt>cpan@nystad-johansen.noE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 by Levi Elias Nystad-Johansen

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.40.3 or,
at your option, any later version of Perl 5 you may have available.


=cut

