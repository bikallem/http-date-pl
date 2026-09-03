#!/usr/bin/env swipl
% hello_world.pl - simple SWI-Prolog hello world
%
% Run with: swipl -s hello_world.pl
% (the shebang line is treated as a comment by SWI-Prolog)

:- initialization(main).

main :-
    format('Hello, World!~n', []),
    halt.
