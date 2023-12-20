-module(a20).
-export([a/1, b/1]).

a(In) ->
    L = [parse(L) || L <- ["!rx -> rx" | In]],
    M = maps:from_list(inputs(L, L)),
    C = push(1000, #{true => 0, false => 0, total => 0}, M),
    maps:get(false, C) * maps:get(true, C).

push(0, C, _M) ->
    C;
push(N, C, M) ->
    Q = queue:from_list([{false, "button", "broadcaster"}]),
    {Mx, Cx} = process(M, C, queue:out(Q)),
    push(N - 1, Cx, Mx).

process(M, Count, {empty, _Q}) ->
    {M, Count};
process(M, Count, {{value, {Hl, Src, Target}}, Q}) ->
    Cx = maps:update_with(Hl, fun(V) -> V + 1 end, Count),
    Total = maps:get(total, Cx),
    {Type, Dst, State} = maps:get(Target, M),
    {Sx, Out, L} =
        case Type of
            bc -> bc(Hl, Dst);
            flip -> flip(Hl, Dst, State);
            inv -> inv(Hl, Total, Src, Dst, State);
            rx -> rx(Hl, State)
        end,
    Qx = send(Out, Target, L, Q),
    process(maps:update(Target, {Type, Dst, Sx}, M), Cx, queue:out(Qx)).

send(_, _, [], Q) -> Q;
send(Out, Target, [H | T], Q) -> send(Out, Target, T, queue:in({Out, Target, H}, Q)).

rx(false, State) -> {State + 1, false, []};
rx(true, State) -> {State, false, []}.

bc(Hl, Dst) -> {{}, Hl, Dst}.

flip(true, _D, S) -> {S, nix, []};
flip(false, D, S) -> {not S, not S, D}.

inv(Hl, Total, Src, D, {S, Cycle}) ->
    Sx = maps:update(Src, Hl, S),
    All = lists:all(fun(V) -> V end, maps:values(Sx)),
    Cx =
        if
            All -> Cycle;
            true -> Total
        end,
    {{Sx, Cx}, not All, D}.

inputs(_L, []) ->
    [];
inputs(L, [{Signal, {Type, Dst}} | Tail]) ->
    Src = [S || {S, {_T, D}} <- L, lists:any(fun(Q) -> Q == Signal end, D)],
    N =
        case Type of
            bc -> {Signal, {Type, Dst, {}}};
            flip -> {Signal, {Type, Dst, false}};
            rx -> {Signal, {Type, Dst, Src}};
            inv -> {Signal, {Type, Dst, {maps:from_list([{S, false} || S <- Src]), 0}}}
        end,
    [N | inputs(L, Tail)].

parse(L) ->
    [Src, Dsts] = string:split(L, " -> "),
    DstList = string:split(Dsts, ", ", all),
    case Src of
        "broadcaster" -> {"broadcaster", {bc, DstList}};
        [$% | Signal] -> {Signal, {flip, DstList}};
        [$& | Signal] -> {Signal, {inv, DstList}};
        [$! | Signal] -> {Signal, {rx, []}}
    end.

b(In) ->
    L = [parse(L) || L <- ["!rx -> rx" | In]],
    M = maps:from_list(inputs(L, L)),
    crx(1, M).

crx(N, M) ->
    Q = queue:from_list([{false, "button", "broadcaster"}]),
    C = #{true => 0, false => 0, total => N},
    {Mx, _Cx} = process(M, C, queue:out(Q)),
    {_, _, [Src]} = maps:get("rx", Mx),
    {_, _, {State, _}} = maps:get(Src, Mx),
    X = [element(2, element(3, maps:get(K, Mx))) || K <- maps:keys(State)],
    Fin = lists:all(fun(Cycle) -> Cycle > 0 end, X),
    if
        Fin ->
            erlang:display(X),
            lists:foldl(fun lcm:lcm/2, 1, X);
        true ->
            crx(N + 1, Mx)
    end.
