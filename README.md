[![Build Status](https://travis-ci.org/samgwise/Lazy-Static.svg?branch=master)](https://travis-ci.org/samgwise/Lazy-Static)

NAME
====

Lazy::Static - Lazy calculation of static values

SYNOPSIS
========

```perl6
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
```

DESCRIPTION
===========

Lazy::Static is a thread-safe alternative to the the `state` keyword for working with static values.

AUTHOR
======

Sam Gillespie <samgwise@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2019 (c) Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

### sub lazy-static

```perl6
sub lazy-static(
    &generator
) returns Mu
```

Creates a closure which lazily returns the result of the generator provided. The generator Callable is executed the first time the closure is called and all calls afterwards will receive the the value from the first call. If the result of the generator is never required it will never be generated. A value generated in a lazy-static closure will persist until it is garbage collected, like a normal scalar.

