-module(a23).
-export([a/1, b/1]).

a(In) ->
    M = maps:from_list([
        {{X, Y}, C}
     || {Y, L} <- lists:enumerate(In), {X, C} <- lists:enumerate(L), C /= $#
    ]),
    {_, Start} = lists:search(fun({_X, Y}) -> Y == 1 end, maps:keys(M)),
    {_, End} = lists:search(fun({_X, Y}) -> Y == length(In) end, maps:keys(M)),
    dgraph(M, sets:new(), Start, End, 0).

nn({X, Y}) -> [{X + Dx, Y + Dy} || {Dx, Dy} <- [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]].

dgraph(_M, _V, End, End, N) ->
    N;
dgraph(M, V, {X, Y} = P, End, N) ->
    Sym = maps:get(P, M),
    Pos =
        case Sym of
            $< -> [{X - 1, Y}];
            $> -> [{X + 1, Y}];
            $v -> [{X, Y + 1}];
            $^ -> [{X, Y - 1}];
            $. -> lists:filter(fun(Q) -> maps:is_key(Q, M) end, nn(P))
        end,
    New = lists:filter(fun(Q) -> not sets:is_element(Q, V) end, Pos),
    case New of
        [] ->
            0;
        [Q] ->
            dgraph(M, V, Q, End, N + 1);
        _ ->
            Vx = sets:add_element(P, V),
            F = fun(Q) -> dgraph(M, Vx, Q, End, N + 1) end,
            lists:max(pmap:unordered(F, New))
    end.

b(In) ->
    M = maps:from_list([
        {{X, Y}, C}
     || {Y, L} <- lists:enumerate(In), {X, C} <- lists:enumerate(L), C /= $#
    ]),
    {_, Start} = lists:search(fun({_X, Y}) -> Y == 1 end, maps:keys(M)),
    {_, End} = lists:search(fun({_X, Y}) -> Y == length(In) end, maps:keys(M)),
    Set = graph(M, sets:new(), maps:keys(M)),
    My = to_map(#{}, sets:to_list(Set)),
    Mx = cut(My, maps:to_list(My), Start, End),
    {V, Longest, Steps} = find(Mx, #{}, [Start], Start, End),
    Pairs = lists:droplast(lists:zip(Steps, tl(Steps) ++ [0])),
    print(Pairs, Mx, Longest),
    V.

find(_M, V, Steps, End, End) ->
    {lists:sum(maps:values(V)), V, lists:reverse(Steps)};
find(M, V, Steps, P, End) ->
    L = maps:get(P, M),
    Pos = lists:filter(fun({K, _}) -> not maps:is_key(K, V) end, L),
    case Pos of
        [] ->
            0;
        [{Q, X}] ->
            find(M, maps:put(Q, X, V), [Q | Steps], Q, End);
        More ->
            F = fun({Q, X}) -> find(M, maps:put(Q, X, V), [Q | Steps], Q, End) end,
            lists:max(lists:map(F, More))
    end.

to_map(M, []) ->
    M;
to_map(M, [{A, B} | T]) ->
    Ma = maps:update_with(A, fun(V) -> [{B, 1} | V] end, [{B, 1}], M),
    Mb = maps:update_with(B, fun(V) -> [{A, 1} | V] end, [{A, 1}], Ma),
    to_map(Mb, T).

cut(M, [], _, _) ->
    M;
cut(M, [{K, [{V, _}]} | T], Start, End) when
    (K == Start) or (V == Start) or (K == End) or (V == End)
->
    cut(M, T, Start, End);
cut(M, [{K, [_]} | _], Start, End) ->
    Mx = maps:remove(K, M),
    cut(Mx, maps:to_list(Mx), Start, End);
cut(M, [{K, [{A, Al}, {B, Bl}]} | _], Start, End) ->
    Ma = maps:remove(K, M),
    Mb = maps:update_with(
        A, fun(V) -> [{B, Al + Bl} | lists:filter(fun({Z, _}) -> Z /= K end, V)] end, Ma
    ),
    Mc = maps:update_with(
        B, fun(V) -> [{A, Al + Bl} | lists:filter(fun({Z, _}) -> Z /= K end, V)] end, Mb
    ),
    cut(Mc, maps:to_list(Mc), Start, End);
cut(M, [_ | T], Start, End) ->
    cut(M, T, Start, End).

graph(_M, S, []) ->
    S;
graph(M, V, [H | T]) ->
    Pos = lists:filter(fun(P) -> maps:is_key(P, M) end, nn(H)),
    graph(M, put(Pos, H, V), T).

put([H | T], O, S) -> put(T, O, sets:add_element({min(O, H), max(O, H)}, S));
put([], _, S) -> S.

print(Pairs, M, Longest) ->
    [
        io:format("~n~p,~p ==> ~p,~p", [A1, A2, B1, B2])
     || {{A1, A2}, {B1, B2}} <- Pairs
    ],
    [
        io:format("~n~p,~p -.-|~p| ~p,~p", [A1, A2, D, B1, B2])
     || {{A1, A2}, L} <- maps:to_list(M),
        {{B1, B2}, D} <- L,
        {A1, A2} > {B1, B2},
        not lists:member({{A1, A2}, {B1, B2}}, Pairs),
        not lists:member({{B1, B2}, {A1, A2}}, Pairs)
    ],
    [io:format("~nstyle ~p,~p fill:#00f,stroke-width:4px", [A, B]) || {A, B} <- maps:keys(Longest)].
