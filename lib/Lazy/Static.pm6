use v6.c;
unit module Lazy::Static:ver<0.0.2>:auth<samgwise>;


=begin pod

=head1 NAME

Lazy::Static - Lazy calculation of static values

=head1 SYNOPSIS

=begin code :lang<perl6>

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

=end code

=head1 DESCRIPTION

Lazy::Static is a thread-safe alternative to the the C<state> keyword for working with static values.

=head1 AUTHOR

Sam Gillespie <samgwise@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 (c) Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

sub lazy-static(&generator) is export {
    #= Creates a closure which lazily returns the result of the generator provided.
    #= The generator Callable is executed the first time the closure is called and all calls afterwards will receive the the value from the first call.
    #= If the result of the generator is never required it will never be generated.
    #= A value generated in a lazy-static closure will persist until it is garbage collected, like a normal scalar.
    my $wrapper;
    my atomicint $guard = 0;
    my Promise $ready .= new;

    # Define an initial closure with guards to ensure single execution of the generator
    $wrapper = -> {
        if atomic-fetch-inc($guard) == 0 {
            my $static = generator;
            $ready.keep($static);
            # Swap the wrapper to a new version returning the value returned by the generator
            $wrapper = -> { $static }
            $static
        }
        else {
            await $ready
        }
    }

    # Return a closure over the mutable wrapper
    -> *@_ {
        $wrapper()
    }
}

#| Turns a subroutine into a lazy-static version
multi sub trait_mod:<is>(Sub $s, :$lazy-static) is export {
    $s.wrap: lazy-static( -> { callsame } )
}

#| Turns a method into a instance scoped lazy-static routine
multi sub trait_mod:<is>(Method $m, :$lazy-static) is export {
    $m.wrap: lazy-static( { callsame } )
}