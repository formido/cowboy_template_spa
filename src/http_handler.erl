-module(http_handler).
-behavior(cowboy_http_handler).

-include_lib("kernel/include/file.hrl").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Type,Req,Root) ->
    {ok,Req,Root}.

handle(Req, State=#state{}) ->
    {ok, Req2} = cowboy_req:reply(200,
        [{<<"content-type">>, <<"text/plain">>}],
        <<"Hello Erlang!">>,
        Req),
        {ok, Req2, State}.

terminate(_Reason,_Req,_) ->
    ok.
				  
				      
