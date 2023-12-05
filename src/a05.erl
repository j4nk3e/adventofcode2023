-module(a05).
-export([a/1, b/1]).

a(In) ->
    [Seed, _, _ | Maps] = In,
    S = parse_Seed(Seed),
    M = parse(Maps, []),
    lists:min([loc(M, X) || X <- S]).

loc([], S) -> S;
loc([M | Mt], X) -> loc(Mt, num(M, X)).

num([], X) -> X;
num([{F, T, O} | _], X) when F =< X, X < T -> X + O;
num([_ | T], X) -> num(T, X).

parse_Seed(Seed) ->
    [list_to_integer(S) || S <- string:split(tl(string:split(Seed, ": ")), " ", all)].

parse([[], _ | T], S) -> [S | parse(T, [])];
parse([], S) -> [S];
parse([H | T], S) -> parse(T, line(H, S)).

line(L, S) ->
    [A, B, C] = [list_to_integer(N) || N <- string:split(L, " ", all)],
    [{B, B + C, A - B} | S].

b(In) ->
    [Seed, _, _ | Maps] = In,
    S = parse_Seed(Seed),
    R = range(S),
    M = parse(Maps, []),
    lists:min([A || {A, _} <- rloc(M, R)]).

range([]) -> [];
range([N, S | T]) -> [{N, N + S} | range(T)].

rloc([], S) -> S;
rloc([M | T], L) -> rloc(T, rnum(lists:sort(M), lists:sort(L))).

rnum(_, []) ->
    [];
rnum([], I) ->
    I;
rnum([{Min, _Max, _D} | _] = M, [{L, R} | It]) when (R =< Min) ->
    [{L, R} | rnum(M, It)];
rnum([{_Min, Max, _D} | Mt], [{L, _R} | _] = I) when (L >= Max) ->
    rnum(Mt, I);
rnum([{Min, Max, D} | _] = M, [{L, R} | It]) when (L >= Min) and (R =< Max) ->
    [{L + D, R + D} | rnum(M, It)];
rnum([{Min, Max, D} | Mt], [{L, R} | It]) when (L >= Min) and (R >= Max) ->
    [{L + D, Max + D} | rnum(Mt, [{Max, R} | It])];
rnum([{Min, Max, D} | _] = M, [{L, R} | It]) when (L =< Min) and (R =< Max) ->
    [{L, Min}, {Min + D, R + D} | rnum(M, It)];
rnum([{Min, Max, D} | Mt], [{L, R} | It]) when (L =< Min) and (R >= Max) ->
    [{L, Min}, {Min + D, Max + D} | rnum(Mt, [{Max, R} | It])].
