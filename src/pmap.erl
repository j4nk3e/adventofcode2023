-module(pmap).
-export([ordered/2, unordered/2]).

unordered(F, L) ->
    S = self(),
    Ref = erlang:make_ref(),
    Count = lists:foldl(
        fun(I, C) ->
            spawn(fun() ->
                do_f(S, Ref, F, I)
            end),
            C + 1
        end,
        0,
        L
    ),
    gather(0, Count, Ref).

do_f(Parent, Ref, F, I) ->
    Parent ! {Ref, (catch F(I))}.

gather(C, C, _) ->
    [];
gather(C, Count, Ref) ->
    receive
        {Ref, Ret} -> [Ret | gather(C + 1, Count, Ref)]
    end.

ordered(F, L) ->
    S = self(),
    % make_ref() returns a unique reference
    % we'll match on this later
    Ref = erlang:make_ref(),
    Count = lists:foldl(
        fun(I, C) ->
            spawn(fun() ->
                do_f(C, S, Ref, F, I)
            end),
            C + 1
        end,
        0,
        L
    ),
    % gather the results
    Res = gather_c(0, Count, Ref),
    % reorder the results
    element(2, lists:unzip(lists:keysort(1, Res))).

do_f(C, Parent, Ref, F, I) ->
    Parent ! {C, Ref, (catch F(I))}.

gather_c(C, C, _) ->
    [];
gather_c(C, Count, Ref) ->
    receive
        {C, Ref, Ret} -> [{C, Ret} | gather_c(C + 1, Count, Ref)]
    end.
