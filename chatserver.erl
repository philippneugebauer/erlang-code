-module(chatserver).
-export([startserver/0, chatserver/1]).
-export([login/1]).

% start by variable_name = chatserver:startserver().
startserver() ->
    Pid = spawn(chatserver, chatserver, [[]]),
    Pid.

chatserver(Chatter) ->
    process_flag(trap_exit, true),
    receive
        {sender, message} ->
            io:format("personalMessage received"),
        	case string:equal(message, "login") of
        		true -> link(sender), chatserver([sender|Chatter]);
        		false -> lists:foreach(fun(N) -> N ! {sender, message, false} end, Chatter), chatserver(Chatter)
            end;
        {sender, receiver, personalMessage} ->
            io:format("personalMessage received"),
        	receiver ! {sender, personalMessage, true},
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
        {sender, message, true} ->
        	io:format("~p: ~p\n",[sender, message]),
        	chatter();
        {sender, message, false} ->
            io:format("ALL: ~p\n",[message]),
            chatter()
    end.

login(Server) ->
	Client = spawn(fun chatter/0),
	Server ! {Client, login},
	Client.

logout(Client) ->
    Client ! terminate.
    