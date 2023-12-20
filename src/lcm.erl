-module(lcm).
-export([lcm/2, gcd/2]).

lcm(A, B) when A > B -> lcm(B, A);
lcm(A, B) -> (B div gcd(A, B)) * A.

gcd(A, 0) -> A;
gcd(A, B) -> gcd(B, A rem B).
