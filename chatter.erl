-module(chatter).
-export([login/2, remote_login/3, create_remote_server_tuple/2]).
-export([logout/1]).
-export([send_message/3]).
-export([send_private_message/4]).

chatter() ->
    receive
        duplicate ->
            io:format("name is already used, process terminated\n");
        success -> 
            io:format("login successful\n"),
            chatter();
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

remote_login(ServerTuple, ServerName, Name) ->
    net_adm:ping(ServerName),
    login(ServerTuple, Name).

create_remote_server_tuple(ServerNode, ServerName) ->
    {ServerName, ServerNode}.

logout(Client) ->
    Client ! terminate.

send_message(Server, Client, Message) ->
    Server ! {Client, Message}.

send_private_message(Server, Client, Receiver, Message) ->
    Server ! {Client, Receiver, Message}.