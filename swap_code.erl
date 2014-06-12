-module(swap_code).
-export([startserver/0, swap/0, swap2/0]).


startserver() ->
    register(server, spawn(swap_code, swap, [])).

swap() ->
	receive
		upgrade -> 
		    code:purge(?MODULE),
            compile:file(?MODULE),
            code:load_file(?MODULE),
			?MODULE:swap2();
		Message -> 
			io:format("~p\n",[Message]), swap()
	end.

swap2() -> 
	receive
		Message -> 
			io:format("upgraded swap: ~p\n",[Message]), swap()
	end.