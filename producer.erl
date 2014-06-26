-module(producer).
-export([send/2]).

start() -> 
 	register(producer,spawn(fun send/0)).

send() ->
    process_flag(trap_exit, true),
	receive ->
		start -> 
			Consumer = spawn_link(fun consumer:receive/0),
 			register(consumer, Consumer),
 			send();
		Number ->
			consumer ! Number,
			send();
		{'EXIT',From,Reason} ->
            unlink(consumer),
            self() ! start,
            send();
		_ -> 
			send()
	end.

producer_send(Number) ->
	producer ! Number.
