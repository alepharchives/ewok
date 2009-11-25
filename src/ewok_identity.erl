%% Copyright 2009 Steve Davis <steve@simulacity.com>
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%% 
%% http://www.apache.org/licenses/LICENSE-2.0
%% 
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(ewok_identity).
-vsn("1.0").
-author('steve@simulacity.com').
%% RFC-4122 <http://www.ietf.org/rfc/rfc4122.txt>
-include("ewok.hrl").

-export([seed/0, key/0, id/0, uuid/0, keystore/0]).
-export([random/0, srandom/0, sha/2, md5/2, timestamp/0, timestamp/2]).
-export([to_string/1]).

-define(UUID_DNS_NAMESPACE, <<107,167,184,16,157,173,17,209,128,180,0,192,79,212,48,200>>).
-define(UUID_URL_NAMESPACE, <<107,167,184,17,157,173,17,209,128,180,0,192,79,212,48,200>>).
-define(UUID_OID_NAMESPACE, <<107,167,184,18,157,173,17,209,128,180,0,192,79,212,48,200>>).
-define(UUID_X500_NAMESPACE, <<107,167,184,20,157,173,17,209,128,180,0,192,79,212,48,200>>).

-define(SERVER, ewok_identity_srv).
-define(KEYSTORE, ".keystore").

%% API
keystore() ->
	Path = ewok:config({ewok, identity, keystore}, "./priv/data"),
	Dir = filename:join(code:lib_dir(ewok), Path),
	case filelib:is_dir(Dir) of
	true ->
		File = filename:join(Dir, ?KEYSTORE),
		case filelib:is_regular(File) of
		true ->	
			{ok, [Term]} = file:consult(File),
			Term;
		false ->
			{error, no_keystore}
		end;
	false ->
		{error, invalid_path}
	end.
	
%% FROM YAWS
%% pretty good seed, but non portable
seed() ->
	Seed = 
		try begin
			URandom = os:cmd("dd if=/dev/urandom ibs=12 count=1 2>/dev/null"),
			<<X:32, Y:32, Z:32>> = list_to_binary(URandom),
			{X, Y, Z}
		end catch 
			_:_ -> now()
		end,
	random:seed(Seed),
	ok.

id() -> random().
uuid() -> list_to_binary(to_string(random())).
key() -> list_to_binary(to_compact_string(random())).


%% @type uuid() = binary(). A binary representation of a UUID

%% Generates a random UUID 
random() ->
    U = <<
        (random:uniform(4294967296) - 1):32,
        (random:uniform(4294967296) - 1):32,
        (random:uniform(4294967296) - 1):32,
        (random:uniform(4294967296) - 1):32
    >>,
    format_uuid(U, 4).

%% Seeds random number generation with erlang:now() and generates a random UUID
srandom() ->
    {A1, A2, A3} = erlang:now(),
    random:seed(A1, A2, A3),
    random().

%% Generates a UUID based on a crypto:sha() hash
sha(Namespace, Name) when is_list(Name) ->
    sha(Namespace, list_to_binary(Name));
%
sha(Namespace, Name) ->
    Context = crypto:sha_update(crypto:sha_update(crypto:sha_init(), namespace(Namespace)), Name),
    U = crypto:sha_final(Context),
    format_uuid(U, 5).

%% Generates a UUID based on a crypto:md5() hash
md5(Namespace, Name) when is_list(Name) ->
    md5(Namespace, list_to_binary(Name));
%
md5(Namespace, Name) ->
    Context = crypto:md5_update(crypto:md5_update(crypto:md5_init(), namespace(Namespace)), Name),
    U = crypto:md5_final(Context),
    format_uuid(U, 3).

%% Generates a UUID based on timestamp
%%
%% Requires that the uuid gen_server is started
%%
timestamp() ->
    gen_server:call(?SERVER, timestamp).

%% @spec timestamp(Node, CS) -> uuid()
%% where
%%      Node = binary()
%%      CS = int()
%% @doc
%% Generates a UUID based on timestamp
%%
timestamp(Node, CS) ->
    {MegaSecs, Secs, MicroSecs} = erlang:now(),
    T = (((((MegaSecs * 1000000) + Secs) * 1000000) + MicroSecs) * 10) + 16#01b21dd213814000,
    format_uuid(T band 16#ffffffff, (T bsr 32) band 16#ffff, (T bsr 48) band 16#ffff, (CS bsr 8) band 16#ff, CS band 16#ff, Node, 1).

%% @spec to_string(UUID) -> string()
%% where
%%      UUID = uuid()
%% @doc
%% Generates a string representation of a UUID
%%
to_compact_string(<<TL:32, TM:16, THV:16, CSR:8, CSL:8, N:48>>) ->
    lists:flatten(io_lib:format("~8.16.0b~4.16.0b~4.16.0b~2.16.0b~2.16.0b~12.16.0b", [TL, TM, THV, CSR, CSL, N])).

to_string(<<TL:32, TM:16, THV:16, CSR:8, CSL:8, N:48>> = _UUID) ->
    lists:flatten(io_lib:format("~8.16.0b-~4.16.0b-~4.16.0b-~2.16.0b~2.16.0b-~12.16.0b", [TL, TM, THV, CSR, CSL, N])).

%%
%% Internal API
%%

namespace(dns) -> ?UUID_DNS_NAMESPACE;
namespace(url) -> ?UUID_URL_NAMESPACE;
namespace(oid) -> ?UUID_OID_NAMESPACE;
namespace(x500) -> ?UUID_X500_NAMESPACE;
namespace(UUID) when is_binary(UUID) -> UUID;
namespace(_) -> error.

format_uuid(TL, TM, THV, CSR, CSL, <<N:48>>, V) ->
    format_uuid(<<TL:32, TM:16, THV:16, CSR:8, CSL:8, N:48>>, V);

format_uuid(TL, TM, THV, CSR, CSL, N, V) ->
    format_uuid(<<TL:32, TM:16, THV:16, CSR:8, CSL:8, N:48>>, V).

format_uuid(<<TL:32, TM:16, THV:16, CSR:8, CSL:8, N:48, _Rest/binary>>, V) ->
    <<TL:32, TM:16, ((THV band 16#0fff) bor (V bsl 12)):16, ((CSR band 16#3f) bor 16#80):8, CSL:8, N:48>>.

