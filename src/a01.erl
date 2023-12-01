-module(a01).
-export([a/1, b/1]).

a(In) ->
    N = lists:map(fun(L) -> extract(L) end, In),
    lists:sum(N).

extract(Line) ->
    Chars = lists:map(fun(C) -> C - $0 end, Line),
    Digits = lists:filter(fun(C) -> (C >= 0) and (C =< 9) end, Chars),
    hd(Digits) * 10 + lists:last(Digits).

b(In) ->
    N = lists:map(fun(L) -> extract(replace(L)) end, In),
    lists:sum(N).

-define(DIGITS, ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]).

digit(S) -> digit(S, ?DIGITS, $1).

digit([C | _], [], _N) ->
    C;
digit(S, [Digit | T], N) ->
    case string:prefix(S, Digit) of
        nomatch -> digit(S, T, N + 1);
        _ -> N
    end.

replace([]) -> [];
replace(L) -> [digit(L) | replace(tl(L))].
