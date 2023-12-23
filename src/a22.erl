-module(a22).
-export([a/1, b/1]).

a(In) ->
    L = lists:enumerate([parse(L) || L <- In]),
    {_, D} = drop_till_stop(sets:new(), L),
    disintegrate([], D, 0).

disintegrate(_, [], N) ->
    N;
disintegrate(L, [{Id, H} | T], N) ->
    {C, _} = drop(sets:new(), L ++ T, []),
    Size = sets:size(C),
    Nx =
        case Size of
            0 -> N + 1;
            _ -> N
        end,
    disintegrate([{Id, H} | L], T, Nx).

parse(L) ->
    [A, B] = [pc(C) || C <- string:split(L, "~")],
    range({A, B}).

drop_till_stop(S, L) ->
    {Sx, D} = drop(sets:new(), L, []),
    N = sets:size(Sx),
    case N of
        0 -> {sets:size(sets:union(Sx, S)), D};
        _ -> drop_till_stop(sets:union(Sx, S), D)
    end.

drop(S, [], Acc) ->
    {S, Acc};
drop(S, [{Id, P} | T], Acc) ->
    G = grounded(P),
    if
        G ->
            drop(S, T, [{Id, P} | Acc]);
        true ->
            Px = move(P),
            O = lists:any(
                fun({_, Q}) -> lists:any(fun(R) -> lists:any(fun(W) -> W == R end, Q) end, Px) end,
                Acc ++ T
            ),
            if
                O -> drop(S, T, [{Id, P} | Acc]);
                true -> drop(sets:add_element(Id, S), T, [{Id, Px} | Acc])
            end
    end.

grounded(L) -> lists:any(fun({_X, _Y, Z}) -> Z == 1 end, L).

move([]) -> [];
move([{X, Y, Z} | T]) -> [{X, Y, Z - 1} | move(T)].

pc(C) ->
    [X, Y, Z] = [list_to_integer(P) || P <- string:split(C, ",", all)],
    {X, Y, Z}.

range({{Xa, Ya, Za}, {Xb, Yb, Zb}}) ->
    [{X, Y, Z} || X <- lists:seq(Xa, Xb), Y <- lists:seq(Ya, Yb), Z <- lists:seq(Za, Zb)].

b(In) ->
    L = lists:enumerate([parse(L) || L <- In]),
    {_S, D} = drop_till_stop(sets:new(), L),
    Q = disintegrate_max([], D),
    lists:sum(
        pmap:unordered(
            fun(X) ->
                {C, _} = drop_till_stop(sets:new(), X),
                C
            end,
            Q
        )
    ).

disintegrate_max(_, []) -> [];
disintegrate_max(L, [H | T]) -> [L ++ T | disintegrate_max([H | L], T)].
