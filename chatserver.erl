-module(chatserver).
-export([chatserver/1]).
-export([login/1]).


chatserver(Chatter) ->
    process_flag(trap_exit,true),
    receive
        {sender, message} ->
        	if message
        		equal(message, "login") -> link(sender), chatserver([sender|Chatter]);
        		_ -> lists:foreach(fun(N) -> N ! {sender,message,false} end, Chatter), chatserver(Chatter);
        {sender, receiver, personalMessage} ->
        	receiver ! {sender, personalMessage,true},
        	chatserver(Chatter);
        kill ->
            lists:foreach(fun(N) -> (unlink(N)) and (N ! terminate) end, Chatter),
            chatserver(Chatter);
        terminate ->
            lists:foreach(fun(N) -> (unlink(N)) and (N ! terminate) end, Chatter);
        {'EXIT',From,Reason} ->
            unlink(From),
            lists:delete(From,Chatter),
            chatserver(Chatter);
        _ ->
            chatserver(Chatter)
    end.

chatter() ->
    receive
        terminate ->
            io:format("~p terminates\n",[self()]);
        {sender, message, personal} ->
        	if personal
        		false -> io:format("ALL: ~p\n",[message]);
        		true -> io:format("~p: ~p\n",[sender, message]);
        	chatter()
    end.

login(Server) ->
	Client = spawn(fun chatter/0)
	Server ! {Client, login}
	Client
	end.