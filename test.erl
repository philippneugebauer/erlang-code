-module(test).
-export([badarg/0]).

badarg() -> 4 + "string".