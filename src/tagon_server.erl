-module(tagon_server).
-export([init/0, test/0]).

-record(card, { id, balance=20.00, tagged_on, tagged_location }).

test() ->
    Server = init(),
    Server ! { register, { 20.0, 1 } },
    Server ! { register, { 20.0, 2 } },
    Server ! { dump },
    Server ! { tag, { self(), 1, "Bride's Glen" } },
    Server ! { dump },
    Server ! { tag, { self(), 1, "Ballaly" } },
    Server ! { dump },
    ok.

init() ->
    spawn(fun() -> loop(orddict:new()) end).


process_card_tag(#card{ id=CardId, balance=Balance, tagged_on=true, tagged_location=_ }, _) ->
    #card{id=CardId, balance=Balance, tagged_on=false };
process_card_tag(#card{ id=CardId, balance=Balance, tagged_on=false, tagged_location=_ }, Location) ->
    #card{id=CardId, balance=Balance-4, tagged_on=true, tagged_location=Location }.


loop(State) ->
    receive
        { register, { Balance, Id } } ->
            loop(orddict:store(Id, #card{ id=Id, balance=Balance, tagged_on=false }, State));
        { tag, { Client, Id, Location } } ->
            { ok, Card } = orddict:find(Id, State),
            ProcessedCard = process_card_tag(Card, Location),
            Client ! { self(), ok },
            loop(orddict:store(Id, ProcessedCard, State));
        { dump } ->
            io:format("----------------------~n"),
            lists:map(fun(E) -> io:format("Element: ~p.~n", [ E ]) end, orddict:to_list(State)),
            io:format("----------------------~n"),
            loop(State);
        Other ->
            io:format("Unknown message: ~p.~n", [ Other ]),
            loop(State)
    end.
