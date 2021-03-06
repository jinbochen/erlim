-module(cy).

-export([login/0, sc/1, gc/1, logout/1, recv/1, loop_recv/1, unknown_cmd/0, unknown_cmd/1]).


login() ->
    {ok, Sock} = gen_tcp:connect("localhost", 8080, [binary, {packet, 0}]),
    Msg = <<"{\"cmd\": \"login\", \"name\": \"13560474456\", \"pass\": \"12345678\", \"ack\": \"72cdf1ae-62a3-4ebf-821c-a809d1931293\", \"device\": \"android-xiaomi\"}">>,
    ok = gen_tcp:send(Sock, Msg),
    Sock.

sc(Sock) ->
    Msg = iolist_to_binary([<<"{\"cmd\": \"single_chat\", \"to\": 2, \"msg\": \"hello world\", \"ack\": \"72cdf1ae-62a3-4ebf-821c-a809d1931293\"}">>]),
    ok = gen_tcp:send(Sock, Msg).

gc(Sock) ->
    Msg = iolist_to_binary([<<"{\"cmd\": \"group_chat\", \"to\": 1, \"msg\": \"hello world, xiaomi\", \"ack\": \"72cdf1ae-62a3-4ebf-821c-a809d1931293\"}">>]),
    ok = gen_tcp:send(Sock, Msg).

logout(Sock) ->
    Msg = iolist_to_binary([<<"{\"cmd\": \"logout\"}">>]),
    ok = gen_tcp:send(Sock, Msg),
    ok = gen_tcp:close(Sock).

recv(Socket) ->
    receive
        {tcp, Socket, Data} ->
            _IsJSON = jsx:is_json(Data),
            Json = jiffy:decode(Data),
            io:format("Json is ~p.~n", [Json]),
            {[{<<"cmd">>, Cmd} | T]} = Json,
            case Cmd of
                <<"ack">> ->
                    [{<<"action">>, Action}, {<<"ack">>, _Ack}] = T,
                    case Action of
                        <<"login">> ->
                            io:format("Login success");
                        <<"single_chat">> ->
                            io:format("Single chat msg send success");
                        <<"group_chat">> ->
                            io:format("Group chat msg send success")
                    end;
                <<"single_chat">> ->
                    [{<<"from">>, From}, {<<"msg">>, Msg}, {<<"ack">>, MsgId}] = T,
                    io:format("Recv msg ~p, from ~p, ack is ~p", [Msg, From, MsgId]),
                    DataToSend = jiffy:encode({[{<<"cmd">>, <<"ack">>}, {<<"action">>, <<"single_chat">>}, {<<"ack">>, MsgId}]}),
                    ok = gen_tcp:send(Socket, DataToSend);
                <<"group_chat">> ->
                    [{<<"from">>, From}, {<<"to">>, To}, {<<"msg">>, Msg}, {<<"ack">>, UserRoommsgId}] = T,
                    io:format("Recv msg ~p, from ~p, to room ~p, ack is ~p", [Msg, From, To, UserRoommsgId]),
                    DataToSend = jiffy:encode({[{<<"cmd">>, <<"ack">>}, {<<"action">>, <<"group_chat">>}, {<<"ack">>, UserRoommsgId}]}),
                    ok = gen_tcp:send(Socket, DataToSend);
                <<"error">> ->
                    [{<<"msg">>, ErrorMsg}, {<<"code">>, Code}] = T,
                    io:format("Error msg is ~p, Code is ~p~n", [ErrorMsg, Code]);
                _ ->
                    ok
            end
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
