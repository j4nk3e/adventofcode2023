-module(a10).
-export([a/1, b/1]).

a(In) ->
    M = parse(In, 0, #{}),
    NESW = solve(M),
    {_, Loop} = lists:search(fun(L) -> not sets:is_empty(L) end, NESW),
    sets:size(Loop) div 2.

solve(M) ->
    {X, Y} = Start = maps:get(start, M),
    NESW = [{X, Y - 1}, {X + 1, Y}, {X, Y + 1}, {X - 1, Y}],
    [sets:from_list(find_loop(Start, P, Start, M, [{Start, true}])) || P <- NESW].

find_loop(_, S, S, _, N) ->
    N;
find_loop(Prev, Pos, Start, M, N) ->
    Valid = maps:is_key(Pos, M),
    if
        Valid ->
            {A, B, E} = maps:get(Pos, M),
            if
                A == Prev -> find_loop(Pos, B, Start, M, [{Pos, E} | N]);
                B == Prev -> find_loop(Pos, A, Start, M, [{Pos, E} | N]);
                true -> []
            end;
        true ->
            []
    end.

parse([], _, M) -> M;
parse([H | T], Y, M) -> parse(T, Y + 1, parse_line(H, 0, Y, M)).

parse_line([], _, _, M) ->
    M;
parse_line([$. | T], X, Y, M) ->
    parse_line(T, X + 1, Y, M);
parse_line([H | T], X, Y, M) ->
    {Key, Value} =
        case H of
            $F -> {{X, Y}, {{X, Y + 1}, {X + 1, Y}, false}};
            $| -> {{X, Y}, {{X, Y - 1}, {X, Y + 1}, false}};
            $L -> {{X, Y}, {{X, Y - 1}, {X + 1, Y}, false}};
            $7 -> {{X, Y}, {{X, Y + 1}, {X - 1, Y}, true}};
            $- -> {{X, Y}, {{X + 1, Y}, {X - 1, Y}, true}};
            $J -> {{X, Y}, {{X, Y - 1}, {X - 1, Y}, true}};
            $S -> {start, {X, Y}}
        end,
    parse_line(T, X + 1, Y, maps:put(Key, Value, M)).

b(In) ->
    M = parse(In, 0, #{}),
    [_, _, _, W] = NESW = solve(M),
    {_, L} = lists:search(fun(L) -> not sets:is_empty(L) end, NESW),
    Start = maps:get(start, M),
    Loop = maps:put(Start, not sets:is_empty(W), maps:from_list(sets:to_list(L))),
    Line = lists:duplicate(length(hd(In)), false),
    Inside = sweep({Line, []}, Loop, length(In) - 1),
    visualize(Loop, sets:from_list(Inside), In),
    length(Inside).

sweep({_Line, C}, _Loop, -1) -> C;
sweep({Line, C}, Loop, Y) -> sweep(sweep_line([], Line, Loop, 0, Y, C), Loop, Y - 1).

sweep_line(Acc, [], _Loop, _X, _Y, C) ->
    {lists:reverse(Acc), C};
sweep_line(Acc, [Inside | T], Loop, X, Y, C) ->
    Edge = maps:get({X, Y}, Loop, nil),
    Res =
        case {Edge, Inside} of
            {nil, true} -> [{X, Y} | C];
            _ -> C
        end,
    Ins = Inside xor (Edge == true),
    sweep_line([Ins | Acc], T, Loop, X + 1, Y, Res).

visualize(Loop, Inside, In) ->
    io:setopts([{encoding, unicode}]),
    [visualize_line(Loop, Inside, Y, L) || {Y, L} <- lists:enumerate(0, In)].

visualize_line(Loop, Inside, Y, L) ->
    pretty([
        replace(C, {X, Y}, Loop, Inside)
     || {X, C} <- lists:enumerate(0, L)
    ]).

pretty(L) -> io:format("~n~ts", [L]).

replace(C, Pos, Loop, Inside) ->
    E = sets:is_element(Pos, Loop),
    I = sets:is_element(Pos, Inside),
    Q =
        case C of
                $F -> $╔;
                $| -> $║;
                $L -> $╚;
                $7 -> $╗;
                $- -> $═;
                $J -> $╝;
                $S -> color:on_red($╬);
                $. -> $\s
        end,
    if
        E -> color:green(Q);
        I -> color:on_magenta(Q);
        true -> color:rgb([1, 1, 1], Q)
    end.
