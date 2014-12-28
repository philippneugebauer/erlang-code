% The MIT License (MIT)
% Copyright (c) 2014 Philipp Neugebauer
-module(test).
-export([badarg/0]).

badarg() -> 4 + "string".
