-module(a04).
-export([a/1, b/1]).

a(In) ->
    P = [points(parse(L)) || L <- In],
    lists:sum(P).

parse(L) ->
    [_Card, Numbers] = re:split(L, "\\s*\\:\\s*", [trim]),
    [Left, Right] = re:split(Numbers, "\\s*\\|\\s*", [trim]),
    Set = fun(S) -> sets:from_list(re:split(S, "\\s+", [trim])) end,
    sets:size(sets:intersection(Set(Left), Set(Right))).

points(0) -> 0;
points(C) -> round(math:pow(2, C - 1)).

b(In) -> collect(0, [{1, parse(L)} || L <- In]).

collect(Acc, []) -> Acc;
collect(Acc, [{C, 0} | T]) -> collect(Acc + C, T);
collect(Acc, [{C, W} | T]) -> collect(Acc + C, push(T, W, C)).

push(L, 0, _C) -> L;
push([{H, G} | T], N, C) -> [{H + C, G} | push(T, N - 1, C)].
