-module(a19).
-export([a/1, b/1]).

a(In) ->
    {Rules, Parts} = parse(In),
    lists:sum([V || P <- Parts, eval(Rules, P, "in"), V <- maps:values(P)]).

eval(Rules, Part, Key) ->
    R = maps:get(Key, Rules, Key),
    Check = check(R, Part),
    case Check of
        "R" -> false;
        "A" -> true;
        K -> eval(Rules, Part, K)
    end.

check([{Key, Op, Value, Target} | T], Part) ->
    V = maps:get(Key, Part),
    Ok =
        case Op of
            $< -> V < Value;
            $> -> V > Value
        end,
    case Ok of
        true -> Target;
        false -> check(T, Part)
    end;
check([Default], _Part) ->
    Default.

parse(L) ->
    {Parts, Rules} = lists:partition(
        fun([H | _]) -> H == ${ end, lists:filter(fun(S) -> S /= "" end, L)
    ),
    {parse_rules(Rules, #{}), parse_parts(Parts)}.

parse_rules([], M) ->
    M;
parse_rules([H | T], M) ->
    {match, [K, V]} = re:run(H, "(\\w+){(.*)}", [{capture, all_but_first, list}]),
    L = [create_rule(S) || S <- string:split(V, ",", all)],
    parse_rules(T, maps:put(K, L, M)).

create_rule(S) ->
    L = string:split(S, ":"),
    case L of
        [Cond, Target] ->
            [Key, Op | Value] = Cond,
            {Key, Op, list_to_integer(Value), Target};
        [Target] ->
            Target
    end.

parse_parts([]) ->
    [];
parse_parts([H | T]) ->
    {match, L} = re:run(H, "{x=(\\d+),m=(\\d+),a=(\\d+),s=(\\d+)}", [
        {capture, all_but_first, list}
    ]),
    [X, M, A, S] = [list_to_integer(P) || P <- L],
    [#{$x => X, $m => M, $a => A, $s => S} | parse_parts(T)].

b(In) ->
    {Rules, _} = parse(In),
    Range = {1, 4000},
    comb(Rules, "in", #{$x => Range, $m => Range, $a => Range, $s => Range}).

comb(_Rules, "A", Poss) ->
    F = fun(_K, {Min, Max}, Acc) -> Acc * max(Max - Min + 1, 0) end,
    maps:fold(F, 1, Poss);
comb(_Rules, "R", _Poss) ->
    0;
comb(Rules, R, Poss) ->
    L = maps:get(R, Rules),
    c(Rules, L, Poss).

c(Rules, [{Key, Op, Value, Target} | Tail], Poss) ->
    {Min, Max} = maps:get(Key, Poss),
    T =
        case Op of
            $< -> {Min, min(Max, Value - 1)};
            $> -> {max(Min, Value + 1), Max}
        end,
    F =
        case Op of
            $< -> {max(Min, Value), Max};
            $> -> {Min, min(Max, Value)}
        end,
    TPoss = maps:update(Key, T, Poss),
    FPoss = maps:update(Key, F, Poss),
    comb(Rules, Target, TPoss) + c(Rules, Tail, FPoss);
c(Rules, [Default], Poss) ->
    comb(Rules, Default, Poss).
