-module(a16).
-export([a/1, b/1]).

a(In) ->
    M = parse(In),
    W = length(hd(In)),
    H = length(In),
    Pos = {1, 1},
    Dir = {1, 0},
    L = count(Pos, Dir, M, W, H),
    print([], sets:from_list(L), 1, 1, W, H),
    length(L).

count(Pos, Dir, M, W, H) ->
    lists:uniq([P || {P, _D} <- sets:to_list(beam(M, sets:new(), Pos, Dir, W, H))]).

parse(In) -> maps:from_list(lists:flatten([parse(Y, L) || {Y, L} <- lists:enumerate(In)])).
parse(Y, L) -> [{{X, Y}, C} || {X, C} <- lists:enumerate(L), C /= $.].

beam(M, Hist, {X, Y} = P, D, W, H) ->
    Loop = sets:is_element({P, D}, Hist),
    if
        Loop or (X == 0) or (Y == 0) or (X > W) or (Y > H) ->
            Hist;
        true ->
            lists:foldl(
                fun({Dx, Dy} = Dn, He) -> beam(M, He, {X + Dx, Y + Dy}, Dn, W, H) end,
                sets:add_element({P, D}, Hist),
                next(maps:get(P, M, empty), D)
            )
    end.

next($/, {X, Y}) -> [{-Y, -X}];
next($\\, {X, Y}) -> [{Y, X}];
next($|, {_, 0}) -> [{0, 1}, {0, -1}];
next($-, {0, _}) -> [{1, 0}, {-1, 0}];
next(_, D) -> [D].

print(Acc, M, X, Y, X, H) ->
    erlang:display(lists:reverse(Acc)),
    print([], M, 0, Y + 1, X, H);
print(_Acc, _M, _X, Y, _W, H) when Y >= H -> ok;
print(Acc, M, X, Y, W, H) ->
    Hit = sets:is_element({X, Y}, M),
    if
        Hit -> print([$# | Acc], M, X + 1, Y, W, H);
        true -> print([$. | Acc], M, X + 1, Y, W, H)
    end.

b(In) ->
    M = parse(In),
    W = length(hd(In)),
    H = length(In),
    lists:max(
        lists:flatten([
            [length(count({1, Y}, {1, 0}, M, W, H)) || Y <- lists:seq(1, H)],
            [length(count({W, Y}, {-1, 0}, M, W, H)) || Y <- lists:seq(1, H)],
            [length(count({X, 1}, {0, 1}, M, W, H)) || X <- lists:seq(1, W)],
            [length(count({X, H}, {0, -1}, M, W, H)) || X <- lists:seq(1, W)]
        ])
    ).
