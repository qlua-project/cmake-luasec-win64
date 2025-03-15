LuaSec

LuaSec depends on OpenSSL, and integrates with LuaSocket.

- - - -

https://github.com/lunarmodules/luasec

  https://github.com/lunarmodules/luasec/pull/203 (:shutdown before :close)
    allows applications to separate ending the TLS session from closing the underlying socket

  https://github.com/lunarmodules/luasec/pull/38 (+ https redirects)
    https://github.com/lunarmodules/luasocket/pull/133 (expose parseRequest methods)

- - - -

Compilation Notes

By default, this version includes options for OpenSSL 3.0.8
If you need to generate the options for a different version of OpenSSL:s
    $ cd src
    $ lua options.lua -g /usr/include/openssl/ssl.h 3.0.8 > options.c

Modules
  luasocket (luasocket.lib)
    Socket compatibilization module
      a comfortable platform independent interface to sockets
    -DLUASOCKET_DEBUG
      push time elapsed during operation as the last return value
        conn:send, conn:receive
  luasec (ssl.dll)
    -DWITH_LUASOCKET
      Compile with build-in LuaSocket's help files.
      Comment this if you will link with non-internal LuaSocket's help files.
        socket_open
          WSAStartup
        socket_close
          WSACleanup();
            ?? never called

Artifacts
  ssl/https.lua
  ssl.lua
  ssl.dll

OpenSSL
  https://github.com/openssl/openssl/blob/master/NOTES-WINDOWS.md#linking-native-applications

Methods
  require("ssl.core")
      .compression(ssl)
      .create(ctx)
      .info(ssl)
      .setfd()
      .setmethod("info", info)
      .copyright()
      .SOCKET_INVALID
    SSL:Connection
      :close
      :getalpn
      :getfd
      :getfinished
      :getpeercertificate
      :getlocalcertificate
      :getpeerchain
      :getlocalchain
      :getpeerverification
      :getpeerfinished
      :exportkeyingmaterial
      :getsniname
      :getstats
      :setstats
      :dirty
      :dohandshake
      :receive
      :send
      :settimeout
      :sni
      :want
    #if LSEC_ENABLE_DANE {
      :setdane
      :settlsa
    }
    SSL:SNI:Registry

  require("ssl.context")
      .create
      .locations
      .loadcert
      .loadkey
      .checkkey
      .setalpn
      .setalpncb
      .setcipher
      .setciphersuites
      .setdepth
      .setdhparam
      .setverify
      .setoptions
    #if LSEC_ENABLE_PSK {
      .setpskhint
      .setserverpskcb
      .setclientpskcb
    }
      .setmode
    #if ! OPENSSL_NO_EC {
      .setcurve
      .setcurveslist
    }
    #if LSEC_ENABLE_DANE {
      .setdane
    }
    SSL:DH:Registry
    SSL:ALPN:Registry
    SSL:PSK:Registry
    SSL:Verify:Registry
    SSL:Context

  require("ssl.x509")
  require("ssl.config")

- - - -

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
