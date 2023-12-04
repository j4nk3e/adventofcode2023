-module(a04).
-export([a/1, b/1]).

a(I)->P=[x(p(L))||L<-I],lists:sum(P). p(L)->[_,N]=re:split(L,":\\s*"),[A,B]=re:
split(N,"\\s*\\|\\s*"),S=fun(S)->sets:from_list(re:split(S,"\\s+"))end,sets:size
(sets:intersection(S(A),S(B))). x(0)->0;x(C)->round(math:pow(2,C-1)). b(I)->c(0,
[{1,p(L)}||L<-I]). c(A,[])->A;c(A,[{C,0}|T])->c(A+C,T);c(A,[{C,W}|T])->c(A+C,d(T
,W,C)). d(L,0,_)->L;d([{H,G}|T],N,C)->[{H+C,G}|d(T,N-1,C)].
