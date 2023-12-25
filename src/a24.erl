-module(a24).
-export([a/1, b/1]).

a(In) ->
    H = [parse(L) || L <- In],
    I = [
        {A, B, intersect_2d(drop_zz(A), drop_zz(B))}
     || {Ia, A} <- lists:enumerate(H),
        {Ib, B} <- lists:enumerate(H),
        Ia < Ib
    ],
    %{Min, Max} = {7, 27},
    {Min, Max} = {200000000000000, 400000000000000},
    IR = fun(C) -> (C >= Min) and (C =< Max) end,
    R = lists:filter(fun({_, _, [X, Y]}) -> IR(X) and IR(Y) end, I),
    F = lists:filter(
        fun({{[Xa, _, _], [Da, _, _]}, {[Xb, _, _], [Db, _, _]}, [Xc, _]}) ->
            ((Xc - Xa > 0) == (Da > 0)) and
                ((Xc - Xb > 0) == (Db > 0))
        end,
        R
    ),
    length(F).

drop_zz({A, B}) -> {drop_z(A), drop_z(B)}.
drop_z([X, Y, _]) -> [X, Y].

intersect_2d({[X1, Y1], [Dx1, Dy1]}, {[X2, Y2], [Dx2, Dy2]}) ->
    Det = Dy2 * Dx1 - Dy1 * Dx2,
    C1 = Dy1 * X1 - Dx1 * Y1,
    C2 = Dy2 * X2 - Dx2 * Y2,
    case Det of
        0 ->
            {nil, nil};
        _ ->
            X = (Dx1 * C2 - Dx2 * C1) / Det,
            Y = (Dy1 * C2 - Dy2 * C1) / Det,
            [X, Y]
    end.

parse(L) ->
    [P, D] = re:split(L, "@", [trim]),
    {parse_coord(P), parse_coord(D)}.

parse_coord(P) ->
    L = re:split(P, ",", [trim, {return, list}]),
    [list_to_integer(string:trim(Q)) || Q <- L].

b(In) ->
    H = [parse(L) || L <- In],
    L = fskew([hd(H)], tl(H)),
    {R, S} = solve(L),
    lists:sum(R) div S.
% 757031940316991

solve([{Pa, Va} = A, {Pb, Vb} = B, C]) ->
    {Aa, Ad} = plane(A, B),
    {Bb, Bd} = plane(A, C),
    {Cc, Cd} = plane(B, C),

    [Wx, Wy, Wz] = lin(Ad, cross(Bb, Cc), Bd, cross(Cc, Aa), Cd, cross(Aa, Bb)),
    T = dot(Aa, cross(Bb, Cc)),
    W = [round(Wx / T), round(Wy / T), round(Wz / T)],
    W1 = sub(Va, W),
    W2 = sub(Vb, W),
    Ww = cross(W1, W2),

    E = dot(Ww, cross(Pb, W2)),
    F = dot(Ww, cross(Pa, W1)),
    G = dot(Pa, Ww),
    S = dot(Ww, Ww),

    R = lin(E, W1, -F, W2, G, Ww),
    {R, S}.

fskew([_, _, _] = L, _) ->
    L;
fskew(S, [H | T]) ->
    All = lists:all(fun(Q) -> skew(Q, H) end, S),
    if
        All -> fskew([H | S], T);
        true -> fskew(S, T)
    end.

skew({_, A}, {_, B}) -> [] == [V || V <- cross(A, B), V == 0].

plane({P1, V1}, {P2, V2}) ->
    P12 = sub(P1, P2),
    V12 = sub(V1, V2),
    V = cross(V1, V2),
    {cross(P12, V12), dot(P12, V)}.

cross([Ax, Ay, Az], [Bx, By, Bz]) -> [Ay * Bz - Az * By, Az * Bx - Ax * Bz, Ax * By - Ay * Bx].

dot([Ax, Ay, Az], [Bx, By, Bz]) -> Ax * Bx + Ay * By + Az * Bz.

sub([Ax, Ay, Az], [Bx, By, Bz]) -> [Ax - Bx, Ay - By, Az - Bz].

lin(R, [Ax, Ay, Az], S, [Bx, By, Bz], T, [Cx, Cy, Cz]) ->
    X = R * Ax + S * Bx + T * Cx,
    Y = R * Ay + S * By + T * Cy,
    Z = R * Az + S * Bz + T * Cz,
    [X, Y, Z].
