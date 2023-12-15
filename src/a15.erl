-module(a15).
-export([a/1, b/1]).

a(In) ->
    lists:sum([hash(S, 0) || S <- string:split(hd(In), ",", all)]).

hash([], N) -> N;
hash([H | T], N) -> hash(T, ((N + H) * 17) rem 256).

b(In) ->
    S = [S || S <- string:split(hd(In), ",", all)],
    R = wtf(S, maps:from_list(lists:enumerate(0, lists:duplicate(256, [])))),
    L = [(1 + I) * J * (F - $0) || {I, L} <- maps:to_list(R), {J, {_, F}} <- lists:enumerate(L)],
    lists:sum(L).

wtf([], M) ->
    M;
wtf([S | T], M) ->
    L = hd(string:split(hd(string:split(S, "=")), "-")),
    H = hash(L, 0),
    wtf(T, maps:update_with(H, fun(V) -> op(V, lists:reverse(S)) end, M)).

op([{H, _V} | T], [$- | H]) -> T;
op([{H, _V} | T], [F, $= | H]) -> [{H, F} | T];
op([H | T], N) -> [H | op(T, N)];
op([], [F, $= | H]) -> [{H, F}];
op([], _N) -> [].
