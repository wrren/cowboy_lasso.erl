%%
%%	@author Warren Kenny
%%	@doc Middleware for use with cowboy 1.0 or 2.0. Looks for a 'roles' property within
%%	the provided environment variable's 'lasso' map and attempts to determine the roles required by the
%%	requested handler by calling Handler:roles( Req ). The 'roles' property must be provided
%%	by a preceeding middleware and will depend on your session management approach.
%%
-module( cowboy_lasso ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).
-export( [execute/2] ).

-type role() :: atom().
-export_type( [role/0] ).

-spec execute( cowboy:req(), cowboy_middleware:env() ) -> 
	{ ok, cowboy:req(), cowboy_middleware:env() } 	|
	{ suspend, module(), atom(), [any()] } 			|
	{ stop, cowboy:req() }.
execute( Req, Env = #{ lasso := #{ roles := Roles }, handler := Handler } ) ->
	execute( Req, Env, Roles, Handler );

%%
%%	Missing env keys
%%
execute( Req, Env ) ->
	{ ok, Req, Env }.

-spec execute( cowboy:req(), cowboy_middleware:env(), [role()], module() ) -> { ok, cowboy:req(), cowboy_middleware:env() } | { stop, cowboy:req() }.
execute( Req, Env, Roles, Handler ) ->
	case match_roles( Req, Roles, Handler ) of
		true 	-> { ok, Req, Env };
		false 	-> reject( Req, Env )
	end.

-spec match_roles( cowboy:req(), [role()], module() ) -> boolean().
match_roles( Req, Roles, Handler ) ->
	HandlerRoles = Handler:roles( Req ),
	case erlang:function_exported( Handler, roles, 1 ) of
		true 	-> lists:any( fun( Role ) -> lists:member( Role, Roles ) end, HandlerRoles );
		false 	-> true
	end.

%%
%%	Reject the request and either stop with a 401, 403 or a redirect, depending on the configuration passed through the env variable
%%
-spec reject( cowboy:req(), cowboy_middleware:env() ) -> { stop, cowboy:req() }.
reject( Req, #{ lasso := #{ signed_in := false, reject := { redirect, To } } } ) ->
	{ stop, cowboy_req:reply( 301, #{ <<"Location">> => To }, <<>>, Req ) };

reject( Req, #{ lasso := #{ signed_in := false } } ) ->
	{ stop, cowboy_req:reply( 401, #{}, <<>>, Req ) };

reject( Req, #{ lasso := #{ signed_in := true } } ) ->
	{ stop, cowboy_req:reply( 403, #{}, <<>>, Req ) }.