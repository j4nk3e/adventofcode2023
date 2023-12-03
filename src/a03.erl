-module(a03).
-export([a/1, b/1]).

a(In) ->
    {Symbols, Numbers} = parse(In, 0, {#{}, #{}}),
    K = maps:keys(maps:from_list(adj_sym(Symbols, Numbers))),
    lists:sum(K).

parse([], _Y, Acc) -> Acc;
parse([[] | T], Y, Acc) -> parse(T, Y + 1, Acc);
parse([L | T], Y, Acc) -> parse(T, Y + 1, parse_row(L, {0, Y}, Acc)).

parse_row([], _, Acc) ->
    Acc;
parse_row([$. | T], {X, Y}, Acc) ->
    parse_row(T, {X + 1, Y}, Acc);
parse_row([D | T], {X, Y}, Acc) when (D >= $0), (D =< $9) ->
    {Tail, Xn, Num} = parse_digit(T, X, [D]),
    {Symbols, Numbers} = Acc,
    A = {Symbols, maps:put({Xn, Y}, Num, Numbers)},
    parse_row(Tail, {Xn + 1, Y}, A);
parse_row([S | T], {X, Y}, {Symbols, Num}) ->
    A = maps:put({X, Y}, S, Symbols),
    parse_row(T, {X + 1, Y}, {A, Num}).

parse_digit([H | T], X, D) when (H >= $0), (H =< $9) ->
    parse_digit(T, X + 1, [H | D]);
parse_digit(T, X, D) ->
    Num = list_to_integer(lists:reverse(D)),
    {T, X, Num}.

adj_sym(S, N) ->
    adj_sym(S, maps:to_list(N), []).
adj_sym(_S, [], N) ->
    N;
adj_sym(S, [{{X, Y}, N} | T], L) ->
    Adj = adjacent(S, {X + 1, Y}, 3 + floor(math:log10(N))),
    case Adj of
        [] -> adj_sym(S, T, L);
        _ -> adj_sym(S, T, [{N, Adj} | L])
    end.

adjacent(_S, _C, 0) ->
    [];
adjacent(S, {X, Y}, N) ->
    F = [{X, Y + Dy} || Dy <- [-1, 0, 1], maps:is_key({X, Y + Dy}, S)],
    [F | adjacent(S, {X - 1, Y}, N - 1)].

b(In) ->
    {S, N} = parse(In, 0, {#{}, #{}}),
    Stars = maps:filter(fun(_K, V) -> V == $* end, S),
    F = adj_sym(Stars, N),
    Gears = maps:values(invert(F, #{})),
    Filtered = lists:filter(fun(V) -> length(V) == 2 end, Gears),
    X = lists:map(fun([A, B]) -> A * B end, Filtered),
    lists:sum(X).

invert([], M) ->
    M;
invert([{_, []} | T], M) ->
    invert(T, M);
invert([{N, [Q | R]} | T], M) ->
    MX = maps:update_with(Q, fun(V) -> [N | V] end, [N], M),
    invert([{N, R} | T], MX).
