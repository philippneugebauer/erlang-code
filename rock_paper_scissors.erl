-module('rock_paper_scissors').
-export([play/1, startserver/0]).

play(Choice) ->
	computer ! {self(), Choice},
	receive
		invalid -> io:format("invalid choice sent\n");
		Message -> io:format("~p\n",[Message])
	end.

startserver() ->
	register(computer, spawn(fun computer/0)).


computer() ->
	Computer = computer_choice(),
	receive
		{Sender, Choice} ->	evaluate(Sender, Computer, Choice), computer();
		terminate -> io:format("server stopped\n")
	end.

evaluate(Sender, Computer, Human) ->
	case Computer of
		'Stein' ->
			case Human of
				'Stein' -> Sender ! draw;
				'Schere' -> Sender ! loss;
				'Papier' -> Sender ! win;
				true -> Sender ! invalid
			end;
		'Schere' ->
			case Human of
				'Stein' -> Sender ! win;
				'Schere' -> Sender ! draw;
				'Papier' -> Sender ! loss;
				true -> Sender ! invalid
			end;
		'Papier' ->
			case Human of
				'Stein' -> Sender ! loss;
				'Schere' -> Sender ! win;
				'Papier' -> Sender ! draw;
				true -> Sender ! invalid
			end;
		true -> Sender ! invalid
	end.

computer_choice() ->
	I = random:uniform(3),
	Choices = ['Stein', 'Schere', 'Papier'],
	lists:nth(I, Choices).
