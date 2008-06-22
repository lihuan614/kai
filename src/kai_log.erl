% Licensed under the Apache License, Version 2.0 (the "License"); you may not
% use this file except in compliance with the License.  You may obtain a copy of
% the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
% License for the specific language governing permissions and limitations under
% the License.

-module(kai_log).
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, terminate/2, handle_cast/2, handle_call/3, handle_info/2,
	 code_change/3]).
-export([stop/0, log/4]).

-include("kai.hrl").

-define(SERVER, ?MODULE).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], _Opts = []).

init(_Args) ->
    case kai_config:get(logfile) of
	undefined ->
	    {ok, []};
	File ->
	    case file:open(File, [write, append]) of
		{ok, Fd} ->
		    {ok, [{fd, Fd}]};
		Error ->
		    Error
	    end
    end.

terminate(_Reason, State) ->
    case lists:keysearch(fd, 1, State) of
	{value, {fd, Fd}} ->
	    file:close(Fd);
	_ -> ok
    end.

log(Type, File, Line, Data, State) ->
    {{Year,Month,Day}, {Hour,Minute,Second}} = erlang:localtime(),
    {_MegaSec, _Sec, Usec} = now(),
    Buf = io_lib:format("~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w.~6..0w [~s] ~s:~w: ~p\n",
			[Year, Month, Day, Hour, Minute, Second, Usec, Type, File, Line, Data]),
    case lists:keysearch(fd, 1, State) of
	{value, {fd, Fd}} ->
	    io:format(Fd, "~s", [Buf]);
	_ ->
	    io:format("~s", [Buf])
    end.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State}.
handle_cast({log, Type, File, Line, Data}, State) ->
    log(Type, File, Line, Data, State),
    {noreply, State}.
handle_info(_Info, State) ->
    {noreply, State}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

stop() ->
    gen_server:call(?SERVER, stop).
log(Type, File, Line, Data) ->
    gen_server:cast(?SERVER, {log, Type, File, Line, Data}).