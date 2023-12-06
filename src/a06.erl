-module(a06).
-export([a/1, b/1]).

a(In) ->
    [T, D] = [parse(L) || L <- In],
    G = [opt(Time, Dist) || {Time, Dist} <- lists:zip(T, D)],
    lists:foldl(fun(X, Acc) -> X * Acc end, 1, G).

parse(L) -> [list_to_integer(I) || I <- tl(re:split(L, "\\s+", [trim, {return, list}]))].

opt(Time, Dist) -> length([1 || R <- lists:seq(1, Time), R * (Time - R) > Dist]).

b(In) ->
    [T, D] = [list_to_integer(parse_join(L)) || L <- In],
    opt(T, D).

parse_join(L) -> lists:concat([I || I <- tl(re:split(L, "\\s+", [trim, {return, list}]))]).
