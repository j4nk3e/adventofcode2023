-module(a25).
-export([a/1, b/1]).

a(In) ->
    I = [string:split(L, ": ") || L <- In],
    J = [{A, string:split(B, " ", all)} || [A, B] <- I],
    M = m(#{}, J),
    %[io:format("{:~s, :~s},~n", [K, V]) || {K, L} <- maps:to_list(M), V <- L, K > V],
    M1 = remove(M, "ljh", "tbg"),
    M2 = remove(M1, "qnv", "mnh"),
    M3 = remove(M2, "mfs", "ffv"),
    L = maps:keys(M3),
    X = sets:size(collect(M3, [hd(L)], sets:new())),
    (maps:size(M3) - X) * X.

remove(M, A, B) ->
    Mx = maps:update_with(B, fun(L) -> lists:delete(A, L) end, M),
    maps:update_with(A, fun(L) -> lists:delete(B, L) end, Mx).

collect(M, L, S) ->
    N = lists:merge([maps:get(A, M) || A <- L, not sets:is_element(A, S)]),
    case N of
        [] -> sets:union(S, sets:from_list(L));
        _ -> collect(M, N, sets:union(S, sets:from_list(L)))
    end.

m(M, []) -> M;
m(M, [{K, L} | T]) -> m(mm(M, K, L), T).

mm(M, _K, []) ->
    M;
mm(M, K, [H | T]) ->
    Mx = maps:update_with(K, fun(V) -> [H | V] end, [H], M),
    My = maps:update_with(H, fun(V) -> [K | V] end, [K], Mx),
    mm(My, K, T).

b(_In) -> "*".
