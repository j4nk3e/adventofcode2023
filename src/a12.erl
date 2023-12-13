-module(a12).
-export([a/1, b/1]).
-compile({parse_transform, memoizer}).
-memoize(com/3).

a(In) ->
    X = [parse(L) || L <- In],
    lists:sum(pmap:unordered(fun com/1, X)).

parse(L) ->
    [S, Conf] = string:split(L, " "),
    C = [list_to_integer(C) || C <- string:split(Conf, ",", all)],
    {S, C}.

b(In) ->
    P = [parse(L) || L <- In],
    X = [
        {
            lists:flatten(lists:join($?, lists:duplicate(5, G))),
            lists:flatten(lists:duplicate(5, C))
        }
     || {G, C} <- P
    ],
    lists:sum(pmap:unordered(fun com/1, X)).

com({G, C}) -> com(G, C, false).

com([], [], _) -> 1;
com([$# | _], [], _) -> 0;
com([$# | _], [0 | _], _) -> 0;
com([_ | G], [0 | Ct], _) -> com(G, Ct, false);
com([], [0 | Ct], _) -> com([], Ct, false);
com([], _, _) -> 0;
com([$. | _], _, true) -> 0;
com([$# | G], [C | Ct], _) -> com(G, [C - 1 | Ct], true);
com([$. | G], C, false) -> com(G, C, false);
com([$. | G], [], _) -> com(G, [], false);
com([$? | G], [], _) -> com(G, [], false);
com([$? | G], [C | Ct], true) -> com(G, [C - 1 | Ct], true);
com([$? | G], [C | Ct], _) -> com(G, [C | Ct], false) + com(G, [C - 1 | Ct], true).
