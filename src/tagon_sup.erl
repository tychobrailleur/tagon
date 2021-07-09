-module(tagon_sup).
-behaviour(supervisor).
-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({ local, ?MODULE }, ?MODULE, []).

init(_Args) ->
    SupFlags = #{strategy => one_for_one, intensity => 3, period => 10},
    ChildSpecs = [#{id => tagon_server,
                    start => {tagon_server, init, [self()]},
                    restart => permanent,
                    shutdown => brutal_kill,
                    type => worker,
                    modules => [tagon_server]}],
    {ok, {SupFlags, ChildSpecs}}.
