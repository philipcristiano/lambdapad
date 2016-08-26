%%% Copyright 2014 Garrett Smith <g@rre.tt>
%%%
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.

-module(lpad_contentful).

-behavior(lpad_data_loader).

-export([handle_data_spec/2]).

%%%===================================================================
%%% Load
%%%===================================================================

get_entries(Data) ->
    Props = structs_to_proplists(Data),
    Items = proplists:get_value(<<"items">>, Props),
    parse_items(Items).

parse_items([{H}|T]) ->
    {Fields} = proplists:get_value(<<"fields">>, H),
    {Sys} = proplists:get_value(<<"sys">>, H),
    Id = proplists:get_value(<<"id">>, Sys),
    Item = [{<<"id">>, Id},
            {<<"fields">>, Fields}],
    [Item |parse_items(T)];
parse_items([]) ->
    [].



structs_to_proplists({Proplist}) ->
    [{Name, structs_to_proplists(Val)} || {Name, Val} <- Proplist];
structs_to_proplists(Other) ->
    Other.

get_content(AccessToken, Space) ->
    {ok, _} = application:ensure_all_started(hackney),
    URL = restc:construct_url(["https://cdn.contentful.com/spaces/",
                              Space,
                              "/entries"],
                              [{"access_token", AccessToken}]),

    {ok, 200, _Headers, Body} = restc:request(get, URL),
    Response = jiffy:decode(Body),
    Entries = get_entries(Response),
    [{<<"entries">>, Entries}].

%%%===================================================================
%%% Data loader support
%%%===================================================================
handle_data_spec({Name, {contentful, AccessToken, Space}}, {Data, Sources}) ->
    Content = get_content(AccessToken, Space),
    {ok, {[{Name, Content}|Data], Sources}};

handle_data_spec({contentful, AccessToken, Space}, {'$root', Sources}) ->
    Content = get_content(AccessToken, Space),
    Data = {Content, Sources},
    {ok, Data};

handle_data_spec(D, DState) ->
    io:format("Contentful: Unhandled thing ~p~n", [D]),
    {continue, DState}.
