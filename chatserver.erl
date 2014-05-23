-module(chatserver).
-export([startserver/0, chatserver/1]).


% start by chatserver:startserver().
% send messages by server ! {message}.
% for remote start console by erl -name x
startserver() ->
    register(server, spawn(chatserver, chatserver, [[]])).

%TODO: restart actual_process in case of error
chatserver(Chatter) ->
    process_flag(trap_exit, true),
    receive
        {Sender, Message} ->
            io:format("message received\n"),
            ChatList = lists:filter(fun({I,_}) -> Sender == I end, Chatter),
            case isEmpty(ChatList) of
                false ->
                    [ChatPerson|_] = ChatList,
                    {_, ChatName} = ChatPerson,
                    lists:foreach(fun({Id,_}) -> Id ! {ChatName, Message, false} end, Chatter);
                true -> Sender ! register
            end,
            chatserver(Chatter);
        {Sender, Name, login} ->
            io:format("loginmessage received\n"),
            ChatPersons = lists:filter(fun({_,ChatName}) -> Name == ChatName end, Chatter),
            case isEmpty(ChatPersons) of
                false -> 
                    Sender ! duplicate, 
                    chatserver(Chatter);
                true -> 
                    Sender ! success, 
                    link(Sender), 
                    chatserver([{Sender, Name}|Chatter])
            end;
        %TODO: does it work really for stopping?
        {'EXIT',From,Reason} ->
            io:format("client ~p stopped\n", [From]),
            unlink(From),
            lists:delete(From,Chatter),
            chatserver(Chatter);
        {Sender, Receiver, PersonalMessage} ->
            io:format("personalMessage received\n"),
            ChatList = lists:filter(fun({I,_}) -> Sender == I end, Chatter),
            case isEmpty(ChatList) of
                false ->
                    [ChatPerson|_] = ChatList,
                    {_, ChatName} = ChatPerson,
                    RecieverList = lists:filter(fun({_,N}) -> N == Receiver end, Chatter),
                    case isEmpty(RecieverList) of
                        false ->
                            [ReceiverTuple|_] = RecieverList,
                            {Id, _} = ReceiverTuple,
                            Id ! {ChatName, PersonalMessage, true};
                        true -> Sender ! receiver_not_exists
                    end;
                true -> Sender ! register
            end,
        	chatserver(Chatter);
        %TODO: does it work properly?
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
isEmpty([_|_]) -> false.
   