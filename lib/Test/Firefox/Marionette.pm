package Test::Firefox::Marionette;
use Firefox::Marionette;
use Test::More;
use List::Util qw<first>;
use Try::Tiny;

our @ISA       = qw<Exporter Firefox::Marionette>;
our @EXPORT    = qw<go_ok follow_link_ok fill_form_ok>;
our @EXPORT_OK = @EXPORT;

require Exporter;

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
        pass $desc;
    }
    catch
    {
        fail $desc;
    }
}

sub find_ok
{
    my ($self, $xpath, $desc) = @_;
    $desc //= sprintf 'check if element by xpath "%s" exist', $xpath;
    unless( $self->SUPER::has($xpath) )
    {
        fail $desc;
        return;
    }

    pass $desc;
    return $self->SUPER::find($xpath);
}

sub find_class_ok
{
    my ($self, $class_name, $desc) = @_;
    $desc //= sprintf 'check if element with class "%s" exist', $class_name;
    unless( $self->SUPER::has_class($class_name) )
    {
        fail $desc;
        return;
    }

    pass $desc;
    return $self->SUPER::find_class($class_name);
}

sub find_id_ok
{
    my ($self, $id, $desc) = @_;
    $desc //= sprintf 'check if element by id "%s" exist', $id;
    unless( $self->SUPER::has_id($id) )
    {
        fail $desc;
        return;
    }

    pass $desc;
    return $self->SUPER::find_id($id);
}

sub find_name_ok
{
    my ($self, $name, $desc) = @_;
    $desc //= sprintf 'check if element by id "%s" exist', $name;
    unless( $self->SUPER::has_name($name) )
    {
        fail $desc;
        return;
    }

    pass $desc;
    return $self->SUPER::find_name($name);
}

sub find_selector_ok
{
    my ($self, $css_selector, $desc) = @_;
    $desc //= sprintf 'check if element by selector "%s" exist', $css_selector;
    unless( $self->SUPER::has_selector($css_selector) )
    {
        fail $desc;
        return;
    }

    pass $desc;
    return $self->SUPER::find_selector($css_selector);
}

sub find_tag_ok
{
    my ($self, $tag_name, $desc) = @_;
    $desc //= sprintf 'check if element of tag "%s" exist', $tag_name;
    unless( $self->SUPER::has_tag($tag_name) )
    {
        fail $desc;
        return;
    }

    pass $desc;
    return $self->SUPER::find_tag($tag_name);
}

sub find_link_ok
{
    my ($self, $text, $desc) = @_;
    $desc //= sprintf 'check if link with text "%s" exist', $text;
    unless( $self->SUPER::has_link($text) )
    {
        fail $desc;
        return;
    }

    pass $desc;
    return $self->SUPER::find_link($text);
}

sub find_partial_ok
{
    my ($self, $text, $desc) = @_;
    $desc //= sprintf 'check if link with partial text "%s" exist', $text;
    unless( $self->SUPER::has_partial($text) )
    {
        fail $desc;
        return;
    }

    pass $desc;
    return $self->SUPER::find_partial($text);
}

sub await_ok
{
    my ($self, $cb, $desc) = @_;
    $desc //= 'awaiting...';
    unless ( $self->await($cb) )
    {
        fail $desc;
        return;
    }
    pass $desc;
    return 1;
}

sub follow_link_ok (&;$)
{
    my $self = shift;
    my ($test_cb, $desc) = @_;

    my @links = $self->links;
    return fail $desc unless @links;

    my $link = first { $test_cb->() } @links;
    return fail $desc unless $link;

    try
    {
        $link->click();
        pass $desc;
    }
    catch
    {
        fail sprintf "%s <%s>", $desc, $_;
    }
}

sub fill_form_ok
{
    my ($self, $form, $fields, $desc) = @_;
    for my $key (keys $fields->%*)
    {
        my $val = $fields->{$key};
        fail sprintf("%s: missing field %s\n", $desc, $key)
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
            fail sprintf("%s: invalid option for %s\n", $desc, $key)
                unless $elem->has_selector(sprintf("option[value='%s']", $val));
            my $opt = $elem->find_selector(sprintf("option[value='%s']", $val));
            $opt->click();
            next;
        }
        $elem->clear();
        $elem->type($val);
    }
    pass $desc;
}

sub submit_form_ok
{
    my ($self, $form, $fields, $desc) = @_;
    $self->fill_form_ok($form, $fields, $desc);
    unless ( $form->has_selector('input[type=submit],button[type=submit]') )
    {
        fail $desc;
        return;
    }
    unless ( $self->script('return arguments[0].reportValidity()', args => [ $form ]) )
    {
        fail sprintf '%s (form validation failed)', $desc;
        return;
    }
    my $submit = $form->find_selector('input[type=submit],button[type=submit]');
    $submit->click();
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
