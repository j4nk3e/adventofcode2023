-module(a11).
-export([a/1, b/1]).

a(In) ->
    Gal = [{X, Y} || {Y, L} <- lists:enumerate(In), {X, C} <- lists:enumerate(L), C == $#],
    GapX = gap(Gal),
    GapY = gap(flip(Gal)),
    dist(GapX, GapY, Gal, 2).

flip(L) -> [{Y, X} || {X, Y} <- L].

dist(GapX, GapY, L, Factor) ->
    D = [
        d_axis(GapX, Xa, Xb, Factor) + d_axis(GapY, Ya, Yb, Factor)
     || {Xa, Ya} <- L, {Xb, Yb} <- L, {Xa, Ya} > {Xb, Yb}
    ],
    lists:sum(D).

d_axis(Gap, A, B, Factor) when A > B -> d_axis(Gap, B, A, Factor);
d_axis(Gap, A, B, Factor) ->
    B - A + length(lists:filter(fun(N) -> (N > A) and (N < B) end, Gap)) * (Factor - 1).

gap(L) ->
    Grouped = maps:to_list(maps:groups_from_list(fun({X, _}) -> X end, L)),
    gap(1, lists:sort(Grouped)).

gap(_From, []) -> [];
gap(From, [{From, _} | T]) -> gap(From + 1, T);
gap(From, L) -> [From | gap(From + 1, L)].

b(In) ->
    Gal = [{X, Y} || {Y, L} <- lists:enumerate(In), {X, C} <- lists:enumerate(L), C == $#],
    GapX = gap(Gal),
    GapY = gap(flip(Gal)),
    dist(GapX, GapY, Gal, 1000000).
