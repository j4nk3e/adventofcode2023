-module(a04).
-export([a/1, b/1]).

a(In) ->
    G = lists:map(fun parse/1, In),
    P = lists:map(fun points/1, G),
    lists:sum(P).

parse(L) ->
    [_Card, Numbers] = re:split(L, "\\s*\\:\\s*", [{return, list}, trim]),
    [Left, Right] = re:split(Numbers, "\\s*\\|\\s*", [{return, list}, trim]),
    Set = fun(S) -> sets:from_list(re:split(S, "\\s+", [{return, list}, trim])) end,
    sets:size(sets:intersection(Set(Left), Set(Right))).

points(0) -> 0;
points(C) -> round(math:pow(2, C - 1)).

b(In) ->
    G = lists:map(fun parse/1, In),
    collect(0, lists:zip(lists:duplicate(length(G), 1), G)).

collect(Acc, []) -> Acc;
collect(Acc, [{C, 0} | T]) -> collect(Acc + C, T);
collect(Acc, [{C, W} | T]) -> collect(Acc + C, push(T, W, C)).

push(L, 0, _C) -> L;
push([{H, G} | T], N, C) -> [{H + C, G} | push(T, N - 1, C)].
