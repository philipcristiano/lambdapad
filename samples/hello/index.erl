-module(index).

-include("lpad.hrl").

data() -> #{msg => "Hello World!"}.

site(_) -> [index].

index(Data) -> page("site/index.html", "index.html", Data).
