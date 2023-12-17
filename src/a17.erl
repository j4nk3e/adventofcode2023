-module(a17).
-export([a/1, b/1]).
-import(lists, [enumerate/1]).

a(In) -> solve(In, fun(D, P, C) -> (D /= P) or (C < 3) end).

solve(In, Filter) ->
    M = maps:from_list([{{X, Y}, C - $0} || {Y, L} <- enumerate(In), {X, C} <- enumerate(L)]),
    Start = {1, 1, {0, 0}, 5},
    H = search(M, #{Start => 0}, [Start], Filter),
    lists:min([C || {{X, Y, _, _}, C} <- maps:to_list(H), X == length(hd(In)), Y == length(In)]).

search(_M, Hist, [], _Filter) ->
    Hist;
search(M, Hist, Changed, Filter) ->
    N = lists:flatmap(fun(E) -> path(M, E, Hist, Filter) end, Changed),
    {Hx, New} = update(M, Hist, N, []),
    search(M, Hx, New, Filter).

update(_M, H, [], Acc) ->
    {H, lists:uniq(Acc)};
update(M, H, [{N, C} | T], Acc) ->
    V = maps:get(N, H, new),
    if
        C < V ->
            update(M, maps:put(N, C, H), T, [N | Acc]);
        true ->
            update(M, H, T, Acc)
    end.

path(M, {X, Y, Dir, Count} = P, Hist, Filter) ->
    Cost = maps:get(P, Hist),
    [
        {{Xn, Yn, D, C}, Cost + maps:get({Xn, Yn}, M)}
     || {D, C, Xn, Yn} <- next(Dir, Count, X, Y, Filter),
        maps:is_key({Xn, Yn}, M),
        Cost + maps:get({Xn, Yn}, M) < maps:get({Xn, Yn, D, C}, Hist, new)
    ].

next(P, C, X, Y, Filter) ->
    [
        {D,
            if
                P == D -> C + 1;
                true -> 1
            end, Dx + X,
            Dy + Y}
     || {Dx, Dy} = D <- [{1, 0}, {-1, 0}, {0, 1}, {0, -1}],
        P /= {-Dx, -Dy},
        Filter(D, P, C)
    ].

b(In) -> solve(In, fun(D, P, C) -> ((D == P) or (C >= 4)) and ((D /= P) or (C < 10)) end).
