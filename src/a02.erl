-module(a02).
-export([a/1, b/1]).

a(In) ->
    Lines = lists:map(fun(L) -> parse(L) end, In),
    F = filter(Lines),
    lists:sum(F).

parse(S) ->
    [Game, Cubes] = string:split(S, ": "),
    [_, Id] = string:split(Game, " "),
    Maps = [parse_draw(D) || D <- string:split(Cubes, "; ", all)],
    {list_to_integer(Id), Maps}.

parse_draw(Draw) ->
    Dies = string:split(Draw, ", ", all),
    Tuples = lists:map(fun parse_part/1, Dies),
    maps:from_list(Tuples).

parse_part(Pair) ->
    [Num, Color] = string:split(Pair, " "),
    {list_to_atom(Color), list_to_integer(Num)}.

filter(L) -> [Id || {Id, R} <- L, lists:all(fun check/1, R)].

check(D) ->
    lists:all(fun({C, M}) -> maps:get(C, D, 0) =< M end, [{red, 12}, {green, 13}, {blue, 14}]).

b(In) ->
    M = [power(parse(L)) || L <- In],
    lists:sum(M).

-define(COLORS, [red, green, blue]).

power({_, X}) ->
    M = f_max(X, #{}),
    lists:foldl(fun(Color, Acc) -> maps:get(Color, M) * Acc end, 1, ?COLORS).

f_max([], Acc) ->
    Acc;
f_max([H | T], M) ->
    LMax = [{Color, max_of(Color, H, M)} || Color <- ?COLORS],
    f_max(T, maps:from_list(LMax)).

max_of(Color, MapA, MapB) ->
    A = maps:get(Color, MapA, 0),
    B = maps:get(Color, MapB, 0),
    max(A, B).
