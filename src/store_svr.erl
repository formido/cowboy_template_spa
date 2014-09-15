-module(store_svr).

-behaviour(gen_server).

-define(SERVER, ?MODULE).
-define(RESPONSE_ROOT, code:lib_dir(erl_api_mock) ++ "/test/erl_api_mock").

-record(state, {}).

%% API
-export([start_link/0, save_response/3, start_api_server/1,
	 start_api_server/2, store/3]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

%%====================================================================
%% API
%%====================================================================
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

save_response(Url, IgnoreParams, Response) ->
    gen_server:cast(whereis(?SERVER), {store, Url, IgnoreParams, Response}).

start_api_server(SampleUrl) ->
    start_api_server(SampleUrl, []).

start_api_server(SampleUrl, IgnoreParams) ->
    gen_server:call(whereis(?SERVER), {start_api_server, SampleUrl, IgnoreParams}).

%%====================================================================
%% gen_server callbacks
%%====================================================================
init([]) ->
    ok = filelib:ensure_dir(code:lib_dir(erl_api_mock) ++ "/test/erl_api_mock/"),
    {ok, #state{}}.

handle_call({start_api_server, SampleUrl, IgnoreParams}, _From, State) ->
    io:format("teadsfsasdfhetme~n"),
    handle_start_api_server(SampleUrl, IgnoreParams),
    {reply, ok, State}.

handle_cast({store, Url, IgnoreParams, Response}, State) ->
    store(Url, IgnoreParams, Response),
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%--------------------------------------------------------------------
%%% Internal functions
%%--------------------------------------------------------------------
%% FIXME: doesn't handle APIs without query params
store(Url, IgnoreParams, Response) when is_list(Url) ->
    {ok, {_Scheme, _UserInfo, Host, _Port, Path, Query}} = http_uri:parse(Url),
    Qs = eam:normalize_qs(Query, IgnoreParams),
    Fn = Host ++ Path ++ "/" ++ Qs,
    Fn2 = filename:join(?RESPONSE_ROOT, Fn),
    filelib:ensure_dir(Fn2),
    file:write_file(Fn2, Response).

handle_start_api_server(SampleUrl, IgnoreParams) ->
    {ok, {_Scheme, _UserInfo, Host, _Port, _Path, _Query}} = http_uri:parse(SampleUrl),
    HandlerEnv = [{apihost, Host}, {ignore, IgnoreParams}],
    Dispatch = cowboy_router:compile([
				      {'_',[{'_', mock_handler, HandlerEnv}]}
				     ]),
    Id = list_to_atom(Host),
    cowboy:start_http(Id, 100,
		      [],
		      [{env, [{dispatch,Dispatch}]}]
		     ).


