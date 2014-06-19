-module(swap_code).
-export([startserver/0, print/1, print2/1]).


startserver() ->
    register(server, spawn(swap_code, loop, [fun print/1])).

% code upgrade with server ! {upgrade, fun swap_code:print2/1}.
loop(Function) ->
	receive
		{upgrade, F} ->
			loop(F);
		Message ->
			Function(Message),
			loop(Function)
	end.


print(Message) ->
	io:format("print: ~p\n",[Message]).

print2(Message) ->
	io:format("print2: ~p\n",[Message]).
