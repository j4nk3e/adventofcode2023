-module(a13).
-export([a/1, b/1]).

a(In) ->
    P = parse(In),
    T = [transpose(M) || M <- P],
    lists:sum(
        lists:flatten([
            [100 * mirror(M, maps:size(M) - 1, 0) || M <- P],
            [mirror(M, maps:size(M) - 1, 0) || M <- T]
        ])
    ).

parse([]) ->
    [];
parse(L) ->
    {B, T} = parse(L, 0, []),
    [maps:from_list(B) | parse(T)].

parse([], _, Acc) ->
    {lists:reverse(Acc), []};
parse([[] | T], _, Acc) ->
    {lists:reverse(Acc), T};
parse([H | T], Y, Acc) ->
    parse(T, Y + 1, [{Y, sets:from_list([I || {I, C} <- lists:enumerate(0, H), C == $#])} | Acc]).

transpose(M) ->
    Mx = maps:groups_from_list(fun({X, _Y}) -> X end, [
        {X, Y}
     || {Y, L} <- maps:to_list(M), X <- sets:to_list(L)
    ]),
    maps:map(fun(_K, L) -> sets:from_list([Y || {_X, Y} <- L]) end, Mx).

mirror(_M, 0, _) ->
    0;
mirror(M, N, D) ->
    Check = mirror(M, N - 1, N, D),
    if
        Check -> N;
        true -> mirror(M, N - 1, D)
    end.

mirror(M, L, R, D) ->
    Size = maps:size(M),
    if
        (L < 0) or (R == Size) ->
            D == 0;
        true ->
            Ql = maps:get(L, M),
            Qr = maps:get(R, M),
            Union = sets:union(Ql, Qr),
            Intersection = sets:intersection(Ql, Qr),
            Diff = sets:subtract(Union, Intersection),
            Ds = sets:size(Diff),
            Dx = D - Ds,
            if
                Dx >= 0 -> mirror(M, L - 1, R + 1, Dx);
                true -> false
            end
    end.

b(In) ->
    P = parse(In),
    T = [transpose(M) || M <- P],
    lists:sum(
        lists:flatten([
            [100 * mirror(M, maps:size(M) - 1, 1) || M <- P],
            [mirror(M, maps:size(M) - 1, 1) || M <- T]
        ])
    ).
