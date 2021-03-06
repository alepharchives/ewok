%% Copyright 2009-2010 Steve Davis <steve@simulacity.com>
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
% http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

-module(ewok_data_srv).
-name("Ewok Data Service").
-depends([mnesia]).

-include("ewok.hrl").
-include("ewok_system.hrl").

-behaviour(ewok_service).
-export([start_link/1, stop/0]).
-export([info/0, connect/0, connect/1]).

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, 
	handle_info/2, terminate/2, code_change/3]).

-record(state, {default, ds=[]}).

-define(SERVER, ?MODULE).

%% 
start_link(_Args) ->
	DS = ewok_mnesia_ds:new(),
	case DS:init([]) of
	{ok, Spec = #datasource{}} ->
		gen_server:start_link({local, ?SERVER}, ?MODULE, 
			#state{
				default = mnesia, 
				ds = [Spec#datasource{name = "Ewok DefaultDS", id = default}]
			}, []);
	Error -> 
		ewok_log:fatal({?MODULE, Error}),
		ignore
	end.

%% 
stop() ->
    gen_server:cast(?SERVER, stop).

%%
info() ->
	gen_server:call(?SERVER, {info}, infinity).

%%
connect() ->
	connect(default).
%%
connect(default) ->
	DefaultDS = ewok:config({ewok, datasource, default}, mnesia),
	connect(DefaultDS);
%
connect(mnesia) ->
	{ok, ewok_mnesia_ds:new()};
%
connect(postgres) ->
	not_implemented;
%
connect({aws, sdb}) ->
    AWS_ACCESS_KEY = ewok:config({ewok, aws, sdb_access_key}),
	AWS_SECRET_KEY = ewok:config({ewok, aws, sdb_secret_key}),
	case AWS_ACCESS_KEY =/= undefined andalso AWS_SECRET_KEY =/= undefined of
	true ->	{ok, erlaws_sdb:new(AWS_ACCESS_KEY, AWS_SECRET_KEY, true)};
	false -> {error, no_access}
	end.
	
%%
%%% gen_server
%%
init(Args = #state{}) ->
    process_flag(trap_exit, true), % when do we need this?
    {ok, Args}.
%
handle_call({info}, _From, State) ->
	{reply, State#state.ds, State};
%
handle_call(_Message, _From, State) ->
	{reply, not_implemented, State}.
%%
handle_cast(stop, State) ->
    {stop, normal, State};
%
handle_cast(_, State) ->
    {noreply, State}.
%%
handle_info(_Info, State) ->
    {noreply, State}.
%%
terminate(_Reason, _State) ->
    ok.
%
code_change(_OldVsn, State, _Extra) -> 
	{ok, State}.
