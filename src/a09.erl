-module(a09).
-export([a/1, b/1]).

a(In) ->
    Next = [hd(extra(lists:reverse(parse(L)))) || L <- In],
    lists:sum(Next).

parse(L) -> [list_to_integer(N) || N <- string:split(L, " ", all)].

extra([H | T] = L) ->
    Diff = diff(L),
    Zero = lists:all(fun(N) -> N == 0 end, Diff),
    if
        Zero -> [H | L];
        true -> [hd(extra(Diff)) + H, H | T]
    end.

diff([A, B | T]) -> [A - B | diff([B | T])];
diff([_]) -> [].

b(In) ->
    E = [hd(extra(parse(L))) || L <- In],
    lists:sum(E).
