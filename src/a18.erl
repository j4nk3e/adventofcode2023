-module(a18).
-export([a/1, b/1]).

a(In) ->
    L = [A || {A, _} <- [parse(L) || L <- In]],
    M = lists:sort(maps:to_list(proc(L, 0, #{}))),
    sum(M, 0, 0, 1).

-define(Re, "(\\w) (\\d+) \\(#(.{5})(\\d)\\)").
-define(ItoD, #{0 => $R, 1 => $D, 2 => $L, 3 => $U}).

parse(L) ->
    {match, [[D], N, C, I]} = re:run(L, ?Re, [{capture, all_but_first, list}]),
    {{list_to_integer(N), D}, {list_to_integer(C, 16), maps:get(list_to_integer(I), ?ItoD)}}.

b(In) ->
    L = [B || {_, B} <- [parse(L) || L <- In]],
    M = lists:sort(maps:to_list(proc(L, 0, #{}))),
    sum(M, 0, 0, 1).

sum([], 0, _, S) -> S;
sum([{Y, {0, R}} | T], 0, 0, S) -> sum(T, R, Y, R + S);
sum([{Y, {L, R}} | T], N, Py, S) -> sum(T, N - L + R, Y, N * (Y - Py) + R + S).

proc([], 0, M) ->
    M;
proc([{N, D} | T], Y, M) ->
    Upd = fun(Map, K, Ld, Rd) ->
        maps:update_with(K, fun({L, R}) -> {L + Ld, R + Rd} end, {Ld, Rd}, Map)
    end,
    {Yn, Mx} =
        case D of
            $R -> {Y, Upd(M, Y, 0, N)};
            $D -> {N + Y, Upd(Upd(M, Y + 1, 0, 1), Y + N, 1, 0)};
            $L -> {Y, Upd(M, Y, N, 0)};
            $U -> {Y - N, M}
        end,
    proc(T, Yn, Mx).
