-module(a07).
-export([a/1, b/1]).

a(In) ->
    P = [parse(L) || L <- In],
    lists:sum([I * V || {I, {_, _, V}} <- lists:enumerate(lists:sort(P))]).

parse(L) ->
    [Cards, Bid] = string:split(L, " "),
    Values = #{
        $A => 13,
        $K => 12,
        $Q => 11,
        $J => 10,
        $T => 9,
        $9 => 8,
        $8 => 7,
        $7 => 6,
        $6 => 5,
        $5 => 4,
        $4 => 3,
        $3 => 2,
        $2 => 1
    },
    Val = [maps:get(C, Values) || C <- Cards],
    Groups = lists:reverse(
        lists:sort([
            length(G)
         || {_, G} <- maps:to_list(maps:groups_from_list(fun(X) -> X end, Cards))
        ])
    ),
    {Groups, Val, list_to_integer(Bid)}.

b(In) ->
    P = [parse_b(L) || L <- In],
    lists:sum([I * V || {I, {_, _, V}} <- lists:enumerate(lists:sort(P))]).

parse_b(L) ->
    [Cards, Bid] = string:split(L, " "),
    Values = #{
        $A => 13,
        $K => 12,
        $Q => 11,
        $J => 0,
        $T => 9,
        $9 => 8,
        $8 => 7,
        $7 => 6,
        $6 => 5,
        $5 => 4,
        $4 => 3,
        $3 => 2,
        $2 => 1
    },
    Val = [maps:get(C, Values) || C <- Cards],
    Groups = lists:reverse(
        lists:sort([
            length(G)
         || {C, G} <- maps:to_list(maps:groups_from_list(fun(X) -> X end, Cards)), C /= $J
        ])
    ),
    Jokers = length(maps:get($J, maps:groups_from_list(fun(X) -> X end, Cards), [])),
    [G1 | GT] = Groups ++ [0],
    {[G1 + Jokers | GT], Val, list_to_integer(Bid)}.
