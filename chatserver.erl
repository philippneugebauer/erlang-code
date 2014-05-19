-module(chatserver).
-export([startserver/0, chatserver/1]).
-export([login/2]).
-export([logout/1]).

% start by variable_name = chatserver:startserver().
startserver() ->
    Pid = spawn(chatserver, chatserver, [[]]),
    Pid.

chatserver(Chatter) ->
    process_flag(trap_exit, true),
    receive
        {Sender, Message} ->
            io:format("message received\n"),
            [ChatPerson|_] = lists:filter(fun({I,Name}) -> Sender == I end, Chatter),
            lists:foreach(fun({Id,N}) -> Id ! {ChatPerson, Message, false} end, Chatter), 
            chatserver(Chatter);
        {Sender, Name, login} ->
            io:format("loginmessage received\n"), 
            link(Sender), 
            chatserver([{Sender, Name}|Chatter]);
        {'EXIT',From,Reason} ->
            io:format("client ~p stopped\n", [From]),
            unlink(From),
            lists:delete(From,Chatter),
            chatserver(Chatter);
        {Sender, Receiver, PersonalMessage} ->
            io:format("personalMessage received\n"),
        	Receiver ! {Sender, PersonalMessage, true},
        	chatserver(Chatter);
        kick ->
            io:format("server kicked all clients\n"),
            lists:foreach(fun({Id,N}) -> (unlink(Id)) and (Id ! terminate) end, Chatter),
            chatserver(Chatter);
        terminate ->
            io:format("server terminates\n"),
            lists:foreach(fun({Id,N}) -> (unlink(Id)) and (Id ! terminate) end, Chatter);
        _ ->
            chatserver(Chatter)
    end.

chatter() ->
    receive
        terminate ->
            io:format("~p terminates\n",[self()]);
        {Sender, Message, true} ->
        	io:format("~p to you: ~p\n",[Sender, Message]),
        	chatter();
        {Sender, Message, false} ->
            io:format("~p to ALL: ~p\n",[Sender, Message]),
            chatter()
    end.

login(Server, Name) ->
	Client = spawn(fun chatter/0),
	Server ! {Client, Name, login},
	Client.

logout(Client) ->
    Client ! terminate.

    