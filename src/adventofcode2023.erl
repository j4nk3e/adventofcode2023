-module(adventofcode2023).
-export([main/1]).

%%====================================================================
%% API functions
%%====================================================================

%% escript Entry point
main([Day, Part]) ->
    Lines = read_stdin(),
    io:format("# Day ~s Part ~s~n~p~n", [Day, Part, Lines]),
    D = list_to_atom("a" ++ Day),
    P = list_to_atom(Part),
    Solution = D:P(Lines),
    io:format("~n## Solution~n~p~n", [Solution]),
    erlang:halt(0).

%%====================================================================
%% Internal functions
%%====================================================================

read_stdin() ->
    read_stdin([]).
read_stdin(Acc) ->
    case io:get_line("") of
        eof ->
            lists:reverse(Acc);
        Line ->
            L = string:trim(Line),
            read_stdin([L | Acc])
    end.
