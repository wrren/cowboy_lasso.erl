cowboy_lasso
=====

```cowboy_lasso``` provides a convenient approach to restricting access to your handlers based on the requesting user's role. Lasso requires
that a ```lasso``` key be added to the Cowboy Middleware's environment variable by a preceeding middleware in the chain. The ```lasso``` variable
should be a map with the following keys:

```erlang

#{	signed_in 	:: boolean()					%% Indicates whether there is a user signed in at all
	roles 		:: [cowboy_lasso:role()],		%% Roles for the current user, may be empty
	reject 		:: { redirect, To :: binary() }	%% Optional - If not present, users that aren't signed in will receive a 401 status code
}

```

If the user is signed in, but has incorrect roles for the current request, the request will be stopped with a 403 response code. If the user 
isn't signed in and doesn't have matching roles, lasso will respond with either a 401 status code or will redirect to the location specified
in the ```reject``` tuple if present.

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