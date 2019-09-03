#! /usr/bin/env perl6
use v6;
use Bench;
use lib 'lib';
use Lazy::Static;

my $b = Bench.new;

my &lazy-static-test = lazy-static( -> { 1 } );
my &state-test = sub { state $val = 1; $val };

$b.cmpthese(10000, {
    'Lazy::Static' => sub { lazy-static-test() == 1 },
    'sub w/ State (not threadsafe!)' => sub { state-test() == 1 },
    'State (not threadsafe!)' => sub { state $val = 1; $val == 1 },
});