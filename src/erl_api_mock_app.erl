-module(erl_api_mock_app).
-behavior(application).

-export([start/2,
	stop/1]).

start(_Type,_Args) ->
    Dispatch = cowboy_router:compile([
				      {'_', [{"/", http_handler, []}]}
				     ]),
    cowboy:start_http(my_http_listener, 100, [{port, 8080}],
		      [{env, [{dispatch, Dispatch}]}]
		     ),
    erl_api_mock_sup:start_link().

stop(_State) ->
    ok.
