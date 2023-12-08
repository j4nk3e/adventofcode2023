-module(a08).
-export([a/1, b/1]).

a(In) ->
    [LR, _ | Nodes] = In,
    Map = parse(Nodes, #{}),
    search(fun(P) -> P == "ZZZ" end, 0, "AAA", LR, Map, LR).

parse([], M) ->
    M;
parse([H | T], M) ->
    {match, [N, L, R]} = re:run(H, "(\\w+) = \\((\\w+), (\\w+)\\)", [{capture, all_but_first, list}]),
    parse(T, M#{N => {L, R}}).

search(Fn, Num, Pos, [], Map, LR) ->
    search(Fn, Num, Pos, LR, Map, LR);
search(Fn, Num, Pos, [H | T], Map, LR) ->
    End = Fn(Pos),
    if
        End ->
            Num;
        true ->
            {L, R} = maps:get(Pos, Map),
            Next =
                case H of
                    $L -> L;
                    $R -> R
                end,
            search(Fn, Num + 1, Next, T, Map, LR)
    end.

b(In) ->
    [LR, _ | Nodes] = In,
    Map = parse(Nodes, #{}),
    All = [
        search(fun(P) -> lists:nth(3, P) == $Z end, 0, K, LR, Map, LR)
     || K <- maps:keys(Map), lists:nth(3, K) == $A
    ],
    lists:foldl(fun lcm/2, 1, All).

lcm(A, B) when A > B -> lcm(B, A);
lcm(A, B) -> (B div gcd(A, B)) * A.

gcd(A, 0) -> A;
gcd(A, B) -> gcd(B, A rem B).
