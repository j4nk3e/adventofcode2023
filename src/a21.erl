-module(a21).
-export([a/1, b/1]).

a(In) ->
    E0 = fun(X) -> lists:enumerate(0, X) end,
    L = [{{X, Y}, C} || {Y, L} <- E0(In), {X, C} <- E0(L), C /= $#],
    {_, {Start, _}} = lists:search(fun({_S, C}) -> C == $S end, L),
    Set = sets:from_list(maps:keys(maps:from_list(L))),
    W = length(In),
    Filter = fun({X, Y}) -> sets:is_element({(X rem W + W) rem W, (Y rem W + W) rem W}, Set) end,
    lists:last(path(W, Filter, [Start], 0, 64)).

path(_W, _, _L, Max, Max) ->
    [];
path(W, Filter, L, Gen, Max) ->
    Next = update(L, sets:new()),
    Nx = sets:filter(Filter, Next),
    [sets:size(Nx) | path(W, Filter, sets:to_list(Nx), Gen + 1, Max)].

update([], S) -> S;
update([H | T], S) -> update(T, sets:union(S, sets:from_list(next(H)))).

next({X, Y}) -> [{X + Dx, Y + Dy} || {Dx, Dy} <- [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]].

b(In) ->
    E0 = fun(X) -> lists:enumerate(0, X) end,
    Q = [{{X, Y}, C} || {Y, L} <- E0(In), {X, C} <- E0(L), C /= $#],
    {_, {S, _}} = lists:search(fun({_S, C}) -> C == $S end, Q),
    M = sets:from_list(maps:keys(maps:from_list(Q))),
    W = length(In),
    T = 26501365,
    Limits = [W * N + T rem W || N <- lists:seq(0, 2)],
    Filter = fun({X, Y}) -> sets:is_element({(X rem W + W) rem W, (Y rem W + W) rem W}, M) end,
    V = path(W, Filter, [S], 0, lists:last(Limits)),
    A = [lists:nth(L, V) || L <- Limits],
    s(T div W, A).

s(N, [A0, A1, A2]) ->
    B1 = A1 - A0,
    B2 = A2 - A1,
    A0 + B1 * N + (N * (N - 1) div 2) * (B2 - B1).
