-module(mock_handler).
-behavior(cowboy_http_handler).

-include_lib("kernel/include/file.hrl").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Type,Req,Root) ->
    {ok,Req,Root}.

handle(Req,Opt) ->
    io:format("Path~n"),
    io:format("~p~n", [cowboy_req:path(Req)]),
    io:format("Qs~n"),
    io:format("~p~n", [cowboy_req:qs(Req)]),
    ApiHost = proplists:get_value(apihost, Opt),
    Ignore = proplists:get_value(ignore, Opt),
    io:format("~p~n", [ApiHost]),
    io:format("~p~n", [binary_to_list(element(1, cowboy_req:path(Req)))]),
    {<<$/, Path/binary>>,_Req} = cowboy_req:path(Req),
    {Qs,_Req} = cowboy_req:qs(Req),
    FnParts = [code:lib_dir(erl_api_mock, test)] ++ 
    	["erl_api_mock"] ++
    	[ApiHost] ++ 
    	[binary_to_list(Path)] ++
    	[eam:normalize_qs(Qs,Ignore)],
    io:format("FnParts~n"),
    io:format("~p~n", [FnParts]),
    Fn = filename:join(FnParts),
    io:format("~p~n", [Fn]),

    Sfun = fun(Socket, Transport) -> Transport:sendfile(Socket, Fn) end,
    {ok,#file_info{size=Size}} = file:read_file_info(Fn),
    Req2 = cowboy_req:set_resp_body_fun(Size, Sfun, Req),
    {ok, Req3} = cowboy_req:reply(200, Req2),

    {ok,Req3,Opt}.

terminate(_Reason,_Req,_) ->
    ok.
				  
				      
