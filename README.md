cowboy_lasso
=====

```cowboy_lasso``` provides a convenient approach to restricting access to your handlers based on the requesting user's role. Lasso
requires that a preceeding middleware module be installed that will add a 'roles' property to the middleware environment variable before
Lasso is invoked. Lasso will attempt to invoke the 'roles' function on the handler module chosen by cowboy_router and match the returned
roles against those inserted by the preceeding middleware. If no roles match, the request will halt with status code 403.

Build
-----

    $ rebar3 compile


Install
-------

Add to your ```rebar.config``` ```deps``` property:

```erlang

{ deps, [
	{ cowboy_lasso, 		".*", 	{ git, "git://github.com/wrren/cowboy_lasso.erl", { branch, "master" } } }	
] }.

```