REBAR := rebar
.DEFAULT_GOAL = start

start: get-deps compile erl

pre-compile:
	cp erlim.example.toml /etc/erlim/erlim.toml

get-deps:
	$(REBAR) get-deps

test:
	$(REBAR) compile eunit

compile:
	$(REBAR) compile

release:
	$(REBAR) compile generate

erl:
	erl -pa ebin -pa ./deps/*/ebin -boot start_sasl
