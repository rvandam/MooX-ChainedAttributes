#!/usr/bin/env perl
use strict;
use warnings FATAL => 'all';

use Test::More;

{
    package Foo;

    use Moo;
    use MooX::ChainedAttributes;

    has foo1 => (
        is => 'rw',
        chained => 1,
    );

    has foo2 => (
        is => 'rw',
    );

    has foo3 => (
        is => 'rw',
        writer => 'set_foo3',
        chained => 1,
    );
}

my $f = Foo->new();

is( $f->foo1(32), $f, 'chained accessor returned object' );
is( $f->foo2(56), 56, 'non-chained accessor returned value' );
is( $f->set_foo3(19), $f, 'chained writer returned object' );
is( $f->foo1(), 32, 'chained accessor reader returned value' );

done_testing;
