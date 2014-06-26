-module(consumer).
-export([receive/0]).

receive() ->
	receive
		Number ->
			io:format("~p",[Number]), 
			receive();
		_ -> receive()
	end.

