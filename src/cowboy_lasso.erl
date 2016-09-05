%%
%%	@author Warren Kenny
%%	@doc Middleware for use with cowboy 1.0 or 2.0. Looks for a 'roles' property within
%%	the provided environment variable and attempts to determine the roles required by the
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
execute( Req, Env ) ->
	case { lists:keyfind( roles, 1, Env ), lists:keyfind( handler, 1, Env ) } of
		{ _, false } ->
			erlang:error( no_handler_specified );
		{ false, Handler } -> 
			execute( Req, Env, [], Handler );
		{ Roles, Handler } -> 
			execute( Req, Env, Roles, Handler )
	end.

-spec execute( cowboy:req(), cowboy_middleware:env(), [role()], module() ) -> { ok, cowboy:req(), cowboy_middleware:env() } | { stop, cowboy:req() }.
execute( Req, Env, Roles, Handler ) ->
	case match_roles( Req, Roles, Handler ) of
		true 	-> { ok, Req, Env };
		false 	-> { stop, cowboy_req:reply( 403, #{}, <<>>, Req ) }
	end.

-spec match_roles( cowboy:req(), [role()], module() ) -> boolean().
match_roles( Req, Roles, Handler ) ->
	HandlerRoles = Handler:roles( Req ),
	case erlang:function_exported( Handler, roles, 1 ) of
		true 	-> lists:any( fun( Role ) -> lists:member( Role, Roles ) end, HandlerRoles );
		false 	-> true
	end.
	