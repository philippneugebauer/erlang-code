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
        {Sender, Message} ->
        	case string:equal(Message, "login") of
        		true -> io:format("loginmessage received\n"), link(Sender), chatserver([Sender|Chatter]);
        		false -> io:format("message received\n"), lists:foreach(fun(N) -> N ! {Sender, Message, false} end, Chatter), chatserver(Chatter)
            end;
        {Sender, Receiver, PersonalMessage} ->
            io:format("personalMessage received\n"),
        	Receiver ! {Sender, PersonalMessage, true},
        	chatserver(Chatter);
        kill ->
            lists:foreach(fun(N) -> (unlink(N)) and (N ! terminate) end, Chatter),
            chatserver(Chatter);
        terminate ->
            io:format("server terminates\n"),
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
        {Sender, Message, true} ->
        	io:format("~p: ~p\n",[Sender, Message]),
        	chatter();
        {Sender, Message, false} ->
            io:format("ALL: ~p\n",[Message]),
            chatter()
    end.

login(Server) ->
	Client = spawn(fun chatter/0),
	Server ! {Client, "login"},
	Client.

logout(Client) ->
    Client ! terminate.
    