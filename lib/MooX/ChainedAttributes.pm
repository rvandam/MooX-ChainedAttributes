package MooX::ChainedAttributes;
use strictures 1;

=head1 NAME

MooX::ChainedAttributes - Make your attributes chainable.

=head1 SYNOPSIS

    package Foo;
    use Moo;
    use MooX::ChainedAttributes;
    
    has name => (
        is      => 'rw',
        chained => 1,
    );
    
    has age => (
        is => 'rw',
    );
    
    chain('age');
    
    sub who {
        my ($self) = @_;
        print "My name is " . $self->name() . "!\n";
    }
    
    my $foo = Foo->new();
    $foo->name('Fred')->who(); # My name is Fred!

=head1 DESCRIPTION

Chaining is a questionable feature to support.  It leads to all kinds
of crazyness, all of which just cause developers pain.  It works with
some things like C<jQuery>, but typically it is to be avoided.

That being said, this module exists for your chaining enjoyment.  It
was developed in order to support the porting of
L<MooseX::Attribute::Chained> using classes to L<Moo>.

In L<Moose> you would write:

    package Bar;
    use Moose;
    use MooseX::Attribute::Chained;
    has baz => ( is=>'rw', traits=>['Chained'] );

To port the above to L<Moo> just change it to:

    package Bar;
    use Moo;
    use MooX::ChainedAttributes;
    has baz => ( is=>'rw', chained=>1 );

=cut

use Class::Method::Modifiers qw( install_modifier );

sub import {
    my $target = caller();

    my $around = $target->can('around');
    my $fresh = sub{ install_modifier( $target, 'fresh', @_ ) };

    $fresh->(
        chain => sub{
            my ($methods) = @_;
            $methods = [$methods] if !ref $methods;

            foreach my $method ($methods) {
                $around->(
                    $method => sub{
                        my $orig = shift;
                        my $self = shift;
                        return $self->$orig() if !@_;
                        $self->$orig( @_ );
                        return $self;
                    },
                );
            }
        },
    );

    my $chain = $target->can('chain');

    $around->(
        has => sub{
            my ($orig, $name, %attributes) = @_;

            my $methods = delete $attributes{chained};
            $orig->( $name, %attributes );
            return if !$methods;

            my $writer = $attributes{writer} || $name;

            $chain->( $writer );

            return;
        },
    );

    return;
}

1;
__END__

=head1 AUTHOR

Aran Clary Deltac <bluefeet@gmail.com>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
