-module(index).

%data(_) -> {contentful, "hello.json"}.
data(_) -> {contentful, os:getenv("CONTENTFUL_TOKEN"), "y8ikfrvvrqw5"}.

site(Data) ->
    Static = {"site/index.html", {template, "templates/index.html"}},
    Entries = proplists:get_value(<<"entries">>, Data),
    EntityPages = entity_pages(Entries),
    Site = [Static | EntityPages],
    Site.

entity_pages([Entity | T]) ->
    ID = binary:bin_to_list(proplists:get_value(<<"id">>, Entity)),
    Path = string:join(["site/items/", ID, ".html"], ""),
    PageSpec = {Path, {template, "templates/entity.html", [{<<"entity">>, Entity}]}},
    [PageSpec | entity_pages(T)];

entity_pages([]) ->
    [].
