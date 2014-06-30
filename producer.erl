-module(producer).
-export([start/0, producer_send/1]).

start() -> 
 	register(producer, spawn(fun send/0)),
 	producer ! start.

send() ->
    process_flag(trap_exit, true),
    receive
		start -> 
 			register(consumer, spawn_link(fun consumer:accept/0)),
 			send();
 		{'EXIT',From,Reason} ->
            unlink(consumer),
            self() ! start,
            send();
		Number ->
			consumer ! Number,
			send();
		_ -> 
			send()
	end.

producer_send(Number) ->
	producer ! Number.
