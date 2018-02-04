-module(tagon_sup).
-behaviour(supervisor).
-export([start/0, start_link/1, init/1]).

start() ->
    spawn(fun() -> supervisor:start_link({ local, ?MODULE }, ?MODULE, _Arg = []) end).

start_link(Args) ->
    supervisor:start_link({ local, ?MODULE }, ?MODULE, _Arg= []).

init([]) ->
    { ok, {{ one_for_one, 3, 10 },
          [{ tagon_server,
           {tagon_server, init, [] },
             permanent,
             10000,
             worker,
             []
           }]}}.
