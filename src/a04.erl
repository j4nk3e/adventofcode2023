-module(a04).
-export([a/1, b/1]).

a(In) ->
    G = lists:map(fun parse/1, In),
    P = lists:map(fun points/1, G),
    lists:sum(P).

parse(L) ->
    [_Card, Numbers] = re:split(L, "\\s*\\:\\s*", [{return, list}, trim]),
    [Left, Right] = re:split(Numbers, "\\s*\\|\\s*", [{return, list}, trim]),
    S = fun(X) -> sets:from_list(to_int_list(X)) end,
    sets:size(sets:intersection(S(Left), S(Right))).

points(0) -> 0;
points(C) -> round(math:pow(2, C - 1)).

to_int_list(S) ->
    List = re:split(S, "\\s+", [{return, list}, trim]),
    lists:map(fun(N) -> list_to_integer(N) end, List).

b(In) ->
    G = lists:map(fun parse/1, In),
    collect(0, lists:zip(lists:seq(1, length(G)), G), #{}).

collect(Acc, [], _M) ->
    Acc;
collect(Acc, [{Id, 0} | T], M) ->
    C = maps:get(Id, M, 1),
    collect(Acc + C, T, M);
collect(Acc, [{Id, W} | T], M) ->
    C = maps:get(Id, M, 1),
    Mx = add_cards(M, lists:seq(Id + 1, Id + W), C),
    collect(Acc + C, T, Mx).

add_cards(M, [], _C) -> M;
add_cards(M, [H | T], C) -> add_cards(maps:update_with(H, fun(V) -> V + C end, C + 1, M), T, C).
