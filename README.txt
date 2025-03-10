LuaSec

Client-Server TLS/SSL communication
https://github.com/lunarmodules/luasec/wiki


Client code

    require("socket")
    require("ssl")

    -- TLS/SSL client parameters (omitted)
    local params

    local conn = socket.tcp()
    conn:connect("127.0.0.1", 8888)

    -- TLS/SSL initialization
    conn = ssl.wrap(conn, params)
    conn:dohandshake()
    --
    print(conn:receive("*l"))
    conn:close()

Server code

    require("socket")
    require("ssl")

    -- TLS/SSL server parameters (omitted)
    local params 

    local server = socket.tcp()
    server:bind("127.0.0.1", 8888)
    server:listen()
    local conn = server:accept()

    -- TLS/SSL initialization
    conn = ssl.wrap(conn, params)
    conn:dohandshake()
    --
    conn:send("one line\n")
    conn:close()


Params

    local params = {
      mode = "client",
      protocol = "any",
      key = "/etc/certs/clientkey.pem",
      certificate = "/etc/certs/client.pem",
      cafile = "/etc/certs/CA.pem",
      verify = "peer",
      options = {"all", "no_sslv3"}
    }

Server parameters

    local params = {
      mode = "server",
      protocol = "tlsv1_2",
      key = "/etc/certs/serverkey.pem",
      certificate = "/etc/certs/server.pem",
      cafile = "/etc/certs/CA.pem",
      verify = {"peer", "fail_if_no_peer_cert"},
      options = "all"
    }
