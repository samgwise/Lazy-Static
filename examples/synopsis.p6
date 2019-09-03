#!/usr/bin/env perl6

use Lazy::Static;

# Something for our lazy static closure to pick from
my @options = <foo bar baz>;

my &result = lazy-static -> {
    sleep 2; # Some long running calculation;
    @options.pick
}

# It's thread safe
my @threads = start {
    say result; # This will be the same value, since the generator will only be called once.
} for 1..16;

say "Awaiting execution of lazy-static generator...";
await Promise.allof: @threads;

say '-' x 78;

# We can call it without the wait now, since now the result has been calculated
say result;
