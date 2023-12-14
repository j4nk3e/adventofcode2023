-module(a14).
-export([a/1, b/1]).

a(In) ->
    L = lists:flatten([parse(L, 1, Y) || {Y, L} <- lists:enumerate(1, lists:reverse(In))]),
    M = maps:from_list(L),
    Mx = tilt(M, length(hd(In)), length(In)),
    weight(Mx).

parse([], _X, _Y) -> [];
parse([$# | T], X, Y) -> [{{X, Y}, fixed} | parse(T, X + 1, Y)];
parse([$O | T], X, Y) -> [{{X, Y}, loose} | parse(T, X + 1, Y)];
parse([$. | T], X, Y) -> parse(T, X + 1, Y).

weight(M) -> lists:sum([Y || {{_X, Y}, V} <- maps:to_list(M), V == loose]).

tilt(M, 0, _Fix) -> M;
tilt(M, Col, Fix) -> tilt(move(M, Col, Fix, Fix), Col - 1, Fix).

move(M, _Col, 0, _) ->
    M;
move(M, Col, Y, Fix) ->
    K = {Col, Y},
    IsKey = maps:is_key(K, M),
    if
        IsKey ->
            V = maps:get(K, M),
            case V of
                fixed ->
                    move(M, Col, Y - 1, Y - 1);
                loose ->
                    move(
                        maps:put({Col, Fix}, V, maps:remove(K, M)),
                        Col,
                        Y - 1,
                        Fix - 1
                    )
            end;
        true ->
            move(M, Col, Y - 1, Fix)
    end.

b(In) ->
    L = lists:flatten([parse(L, 1, Y) || {Y, L} <- lists:enumerate(1, lists:reverse(In))]),
    M = maps:from_list(L),
    weight(loop(M, 0, {length(hd(In)), length(In)}, {M, 0})).

rotate(M, W) -> maps:from_list([{{Y, W - X + 1}, V} || {{X, Y}, V} <- maps:to_list(M)]).

-define(N, 1000000000).

loop(M, ?N, _S, _) ->
    M;
loop(M, N, S, {M, Nc}) when N > Nc ->
    Cycle = N - Nc,
    Skip = ((?N - N) div Cycle) * Cycle,
    loop(M, N + Skip, S, {M, N});
loop(M, N, {W, H}, {Mc, Nc}) ->
    M1 = rotate(tilt(M, W, H), W),
    M2 = rotate(tilt(M1, H, W), H),
    M3 = rotate(tilt(M2, W, H), W),
    M4 = rotate(tilt(M3, H, W), H),
    Log = math:log2(N + 1),
    C =
        if
            round(Log) == Log -> {M, N};
            true -> {Mc, Nc}
        end,
    loop(M4, N + 1, {W, H}, C).
