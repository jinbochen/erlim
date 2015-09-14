-module(cy).

-export([login/0, sc/1, gc/1, logout/1, recv/1, loop_recv/1, unknown_cmd/0, unknown_cmd/1]).


login() ->
    {ok, Sock} = gen_tcp:connect("localhost", 8080, [binary, {packet, 0}]),
    Msg = <<"{\"cmd\": \"login\", \"name\": \"13560474456\", \"pass\": \"12345678\"}">>,
    ok = gen_tcp:send(Sock, Msg),
    Sock.

sc(Sock) ->
    Msg = iolist_to_binary([<<"{\"cmd\": \"single_chat\", \"to\": 1, \"msg\": \"hello world\"}">>]),
    ok = gen_tcp:send(Sock, Msg).

gc(Sock) ->
    Msg = iolist_to_binary([<<"{\"cmd\": \"group_chat\", \"to\": 1, \"msg\": \"hello world, xiaomi\"}">>]),
    ok = gen_tcp:send(Sock, Msg).

logout(Sock) ->
    Msg = iolist_to_binary([<<"{\"cmd\": \"logout\"}">>]),
    ok = gen_tcp:send(Sock, Msg),
    ok = gen_tcp:close(Sock).

recv(Socket) ->
    receive
        {tcp, Socket, Data} ->
            io:format("Client received msg is: ~p~n", [Data])
    end.

loop_recv(Socket) ->
    recv(Socket),
    loop_recv(Socket).


unknown_cmd() ->
    {ok, Sock} = gen_tcp:connect("localhost", 3000, [binary, {packet, 0}]),
    Msg = <<"{\"cmd\": \"unknown\"}">>,
    ok = gen_tcp:send(Sock, Msg),
    D = receive
                {tcp, _Socket, Data} ->
                    jiffy:decode(Data)
            end,
    io:format("Msg is ~p~n", [D]).

unknown_cmd(Sock) ->
    Msg = <<"{\"cmd\": \"unknown\"}">>,
    ok = gen_tcp:send(Sock, Msg),
    D = receive
            {tcp, _Socket, Data} ->
                jiffy:decode(Data)
        end,
    io:format("Msg is ~p~n", [D]).
