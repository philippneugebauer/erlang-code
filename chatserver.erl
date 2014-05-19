-module(chatserver).
-export([startserver/0, chatserver/1]).
-export([login/2]).
-export([logout/1]).
-export([sendMessage/3]).
-export([sendPrivateMessage/4]).


% start by variable_name = chatserver:startserver().
startserver() ->
    Pid = spawn(chatserver, chatserver, [[]]),
    Pid.

chatserver(Chatter) ->
    process_flag(trap_exit, true),
    receive
        {Sender, Message} ->
            io:format("message received\n"),
            [ChatPerson|_] = lists:filter(fun({I,_}) -> Sender == I end, Chatter),
            {_, ChatName} = ChatPerson,
            lists:foreach(fun({Id,_}) -> Id ! {ChatName, Message, false} end, Chatter), 
            chatserver(Chatter);
        {Sender, Name, login} ->
            io:format("loginmessage received\n"),
            ChatPersons = lists:filter(fun({_,ChatName}) -> Name == ChatName end, Chatter),
            case isEmpty(ChatPersons) of
                false -> Sender ! duplicate, chatserver(Chatter);
                true -> Sender ! success, link(Sender), chatserver([{Sender, Name}|Chatter])
            end;
        {'EXIT',From,Reason} ->
            io:format("client ~p stopped\n", [From]),
            unlink(From),
            lists:delete(From,Chatter),
            chatserver(Chatter);
        {Sender, Receiver, PersonalMessage} ->
            io:format("personalMessage received\n"),
            [ChatPerson|_] = lists:filter(fun({I,_}) -> Sender == I end, Chatter),
            {_, ChatName} = ChatPerson,
        	Receiver ! {ChatName, PersonalMessage, true},
        	chatserver(Chatter);
        kick ->
            io:format("server kicked all clients\n"),
            lists:foreach(fun({Id,_}) -> (unlink(Id)) and (Id ! terminate) end, Chatter),
            chatserver([]);
        terminate ->
            io:format("server terminates\n"),
            lists:foreach(fun({Id,_}) -> (unlink(Id)) and (Id ! terminate) end, Chatter);
        _ ->
            chatserver(Chatter)
    end.

isEmpty([]) -> true;
isEmpty(_) -> false.


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

logout(Client) ->
    Client ! terminate.

sendMessage(Server, Client, Message) ->
    Server ! {Client, Message}.

sendPrivateMessage(Server, Client, Receiver, Message) ->
    Server ! {Client, Receiver, Message}.


    