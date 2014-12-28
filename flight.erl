% The MIT License (MIT)
% Copyright (c) 2014 Philipp Neugebauer
-module(flight).
-export([fromto/3]).
-export([fromon/3]).


% lists:map(fun({F,T,N,D}) -> N end,
% lists:filter(fun({F2,T2,N2,D2}) -> T2 == london end,
% Flights)).

% from end to start
% takes the flight list, which should be loaded previously
% filter only flights, which flies to london
% just take the number of this flights

%Flights =
%[{new_york,paris,123,[mo,tu,we,fr,sa]},
% {paris,new_york,124,[tu,we,th,sa,su]},
% {new_york,london,232,[tu,we,th,fr]},
% {new_york,london,800,[mo,we,fr,sa]},
% {london,new_york,233,[we,th,fr,sa]},
% {london,new_york,801,[tu,th,sa,su]},
% {london,paris,444,[mo,tu,we,th,fr,sa]},
% {paris,london,445,[mo,tu,we,th,fr,sa]}].

fromto(A,B,L) -> lists:filter(fun({F,T,N,D}) -> (T == B) and (F == A) end, L).

fromon(A,D,L) -> lists:map(fun({F,T,N,Day}) -> T end, lists:filter(fun({F2,T2,N2,Day2}) -> (F2 == A) and (lists:filter(fun(T) -> T == D end, Day2) /= []) end, L)).


