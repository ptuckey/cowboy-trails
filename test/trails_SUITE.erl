-module(trails_SUITE).
-author('elbrujohalcon@inaka.net').

-export([all/0]).
-export([init_per_suite/1]).
-export([end_per_suite/1]).
-export([basic_compile_test/1]).
-export([minimal_compile_test/1]).
-export([static_compile_test/1]).
-export([minimal_single_host_compile_test/1]).
-export([basic_single_host_compile_test/1]).
-export([static_single_host_compile_test/1]).
-export([basic_trails2_constructor/1]).
-export([basic_trails3_constructor/1]).
-export([basic_trails4_constructor/1]).
-export([static_trails3_constructor/1]).
-export([static_trails4_constructor/1]).
-export([basic_metadata/1]).
-export([basic_trails_routes/1]).
-export([put_metadata/1]).
-export([post_metadata/1]).
-export([trails_store/1]).


-type config() :: [{atom(), term()}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Common test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-spec all() -> [atom()].
all() ->
  Exports = ?MODULE:module_info(exports),
  [F || {F, 1} <- Exports, F /= module_info].

-spec init_per_suite(config()) -> config().
init_per_suite(Config) ->
  application:ensure_all_started(cowboy),
  Config.

-spec end_per_suite(config()) -> config().
end_per_suite(Config) ->
  Config.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test Cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-spec minimal_compile_test(config()) -> {atom(), string()}.
minimal_compile_test(_Config) ->
  MininalRoute = [{'_', []}],
  ExpectedResponse = cowboy_router:compile(MininalRoute),
  ExpectedResponse = trails:compile(MininalRoute),
  {comment, ""}.

-spec basic_compile_test(config()) -> {atom(), string()}.
basic_compile_test(_Config) ->
  BasicRoute =
    [
      {"localhost",
        [
          {"/such/path", http_such_path_handler, []},
          {"/very", http_very, []}
       ]}
    ],
  ExpectedResponse = cowboy_router:compile(BasicRoute),
  ExpectedResponse = trails:compile(BasicRoute),
  {comment, ""}.

-spec static_compile_test(config()) -> {atom(), string()}.
static_compile_test(_Config) ->
  StaticRoute = get_static_route() ,
  ExpectedResponse = cowboy_router:compile(StaticRoute),
  ExpectedResponse = trails:compile(StaticRoute),
  {comment, ""}.

-spec minimal_single_host_compile_test(config()) -> {atom(), string()}.
minimal_single_host_compile_test(_Config) ->
  MininalRoute = [{'_', []}],
  [{_SingleHost, MininalPath}] = MininalRoute,
  ExpectedResponse = cowboy_router:compile(MininalRoute),
  ExpectedResponse = trails:single_host_compile(MininalPath),
  {comment, ""}.

-spec basic_single_host_compile_test(config()) -> {atom(), string()}.
basic_single_host_compile_test(_Config) ->
  BasicRoute = get_basic_route(),
  ExpectedResponse = cowboy_router:compile(BasicRoute),
  [{_SingleHost, BasicPath}] = BasicRoute,
  ExpectedResponse = trails:single_host_compile(BasicPath),
  {comment, ""}.

-spec static_single_host_compile_test(config()) -> {atom(), string()}.
static_single_host_compile_test(_Config) ->
  StaticRoute = get_static_route(),
  [{_SingleHost, StaticPath}] = StaticRoute,
  ExpectedResponse = cowboy_router:compile(StaticRoute),
  ExpectedResponse = trails:single_host_compile(StaticPath),
  {comment, ""}.

basic_trails2_constructor(_Config) ->
  BasicRoute =
    [
      {'_',
        [
          trails:trail("/such/path", http_basic_route),
          trails:trail("/very", http_very),
          trails:trail("/", http_handler)
       ]}
    ],
  BasicRouteCowboy = get_basic_route(),
  ExpectedResponse = cowboy_router:compile(BasicRouteCowboy),
  ExpectedResponse = trails:compile(BasicRoute),
  {comment, ""}.

basic_trails3_constructor(_Config) ->
  BasicRoute =
    [
      {'_',
        [
          trails:trail("/such/path", http_basic_route, []),
          trails:trail("/very", http_very, []),
          trails:trail("/", http_handler, [])
       ]}
    ],
  BasicRouteCowboy = get_basic_route(),
  ExpectedResponse = cowboy_router:compile(BasicRouteCowboy),
  ExpectedResponse = trails:compile(BasicRoute),
  {comment, ""}.

-spec static_trails3_constructor(config()) -> {atom(), string()}.
static_trails3_constructor(_Config) ->
  StaticRoute =
    [
      {'_',
        [
          trails:trail("/", cowboy_static, {private_file, "index.html"})
        ]}
    ],
  StaticRouteCowboy = get_static_route(),
  [{_SingleHost, StaticPath}] = StaticRoute,
  ExpectedResponse = cowboy_router:compile(StaticRouteCowboy),
  ExpectedResponse = trails:single_host_compile(StaticPath),
  {comment, ""}.

basic_trails4_constructor(_Config) ->
  BasicRouteTrails =
    [
      {'_',
        [
          trails:trail("/such/path", http_basic_route, [], #{}),
          trails:trail("/very", http_very, [], #{}),
          trails:trail("/", http_handler, [], #{})
       ]}
    ],
  BasicRouteCowboy = get_basic_route(),
  ExpectedResponse = cowboy_router:compile(BasicRouteCowboy),
  ExpectedResponse = trails:compile(BasicRouteTrails),
  {comment, ""}.

-spec static_trails4_constructor(config()) -> {atom(), string()}.
static_trails4_constructor(_Config) ->
  StaticRouteTrails =
    [
      {'_',
        [
          trails:trail("/"
                      , cowboy_static
                      , {private_file, "index.html"}
                      , #{}
                      , [])
        ]}
    ],
  StaticRouteCowboy = get_static_route(),
  [{_SingleHost, StaticPath}] = StaticRouteTrails,
  ExpectedResponse = cowboy_router:compile(StaticRouteCowboy),
  ExpectedResponse = trails:single_host_compile(StaticPath),
  {comment, ""}.

 -spec basic_metadata(config()) -> {atom(), string()}.
basic_metadata(_Config) ->
 Metadata = #{ option => 1, description => "Basic Metadata"},
  Trail =
    trails:trail("/"
                , cowboy_static
                , {private_file, "index1.html"}
                , Metadata
                , []),
  Metadata = trails:metadata(Trail),
  {comment, ""}.

 -spec put_metadata(config()) -> {atom(), string()}.
put_metadata(_Config) ->
  Metadata = #{ put => #{ description => "Put method"}},
  Trail =
    trails:trail("/"
                , cowboy_static
                , {private_file, "index2.html"}
                , Metadata
                , []),
  Metadata = trails:metadata(Trail),
  {comment, ""}.

-spec post_metadata(config()) -> {atom(), string()}.
post_metadata(_Config) ->
  Metadata = #{ post => #{ description => "Post method"}},
  Trail =
    trails:trail("/"
                , cowboy_static
                , {private_file, "index3.html"}
                , Metadata
                , []),
  Metadata = trails:metadata(Trail),
  {comment, ""}.

get_static_route() ->
    [
      {'_',
        [
          {"/", cowboy_static, {private_file, "index.html"}}
        ]}
    ].

get_basic_route() ->
    [
      {'_',
        [
          {"/such/path", http_basic_route, []},
          {"/very", http_very, []},
          {"/", http_handler, []}
       ]}
    ].

-spec basic_trails_routes(config()) -> {atom(), string()}.
basic_trails_routes(_Config) ->
  StaticRoutes =
    [ {"/", cowboy_static, {file, "www/index.html"}}
    , {"/favicon.ico", cowboy_static, {file, "www/assets/favicon.ico"}}
    , {"/assets/[...]", cowboy_static, {dir, "www/assets"}}
    , {"/game/:game_id", cowboy_static, {file, "www/game.html"}}
    ],
  ExpectedResponse1 = StaticRoutes ++
    [ {"/api/resource1/[:id]", trails_test_handler, []}
    , {"/api/:id/resource2", trails_test_handler, [arg0]}
    , {"/api/resource3/[:id]", trails_test2_handler, []}
    , {"/api/:id/resource4", trails_test2_handler, [arg0]}
    ],
  ExpectedResponse2 = StaticRoutes ++
    [ {"/api/resource1/[:id]", trails_test_handler, []}
    , {"/api/:id/resource2", trails_test_handler, [arg0]}
    ],
  ExpectedResponse3 = StaticRoutes ++
    [ {"/api/resource3/[:id]", trails_test2_handler, []}
    , {"/api/:id/resource4", trails_test2_handler, [arg0]}
    , {"/api/resource1/[:id]", trails_test_handler, []}
    , {"/api/:id/resource2", trails_test_handler, [arg0]}
    ],
  Handlers1 = [trails_test_handler, trails_test2_handler],
  Handlers2 = [trails_test2_handler, trails_test_handler],
  Trails1 = StaticRoutes ++ trails:trails(Handlers1),
  ExpectedResponse1 = Trails1,
  Trails2 = StaticRoutes ++ trails:trails(trails_test_handler),
  ExpectedResponse2 = Trails2,
  Trails3 = StaticRoutes ++ trails:trails(Handlers2),
  ExpectedResponse3 = Trails3,
  {comment, ""}.

-spec trails_store(config()) -> {atom(), string()}.
trails_store(_Config) ->
  TrailsRaw = [
    {"/resource/[:id]", trails_test_handler, []},
    {"/api/:id/resource", [], trails_test2_handler, [arg0]},
    trails:trail("/assets/[...]", cowboy_static, {dir, "www/assets"}),
    trails:trail("/such/path", http_basic_route, [], #{}),
    trails:trail("/very", http_very, [], #{}),
    trails:trail("/", http_handler, [])
  ],
  {not_started, trails} = (catch trails:all()),
  {not_started, trails} = (catch trails:retrieve("/")),
  ok = trails:store(TrailsRaw),
  Trails = normalize_paths(TrailsRaw),
  Length = length(Trails),
  Length = length(trails:all()),
  Trails = trails:all(),
  #{path_match := "/assets/[...]"} = trails:retrieve("/assets/[...]"),
  #{path_match := "/such/path"} = trails:retrieve("/such/path"),
  #{path_match := "/very"} = trails:retrieve("/very"),
  #{path_match := "/"} = trails:retrieve("/"),
  #{path_match := "/resource/[:id]"} = trails:retrieve("/resource/[:id]"),
  #{path_match := "/api/:id/resource"} = trails:retrieve("/api/:id/resource"),
  notfound = trails:retrieve("/other"),
  {comment, ""}.

%% @private
normalize_paths(RoutesPaths) ->
  [normalize_path(Path) || Path <- RoutesPaths].

%% @private
normalize_path({PathMatch, ModuleHandler, Options}) ->
  trails:trail(PathMatch, ModuleHandler, Options);
normalize_path({PathMatch, Constraints, ModuleHandler, Options}) ->
  trails:trail(PathMatch, ModuleHandler, Options, #{}, Constraints);
normalize_path(Trail) when is_map(Trail) -> Trail.
