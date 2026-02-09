cmake_minimum_required ( VERSION 3.30 )
project ( luasec VERSION 1.3.2.1 LANGUAGES C )

# include ( CMakePrintHelpers )

add_compile_options( /W4 )  # -Wall

set ( LUASEC_HOME src CACHE PATH "Where to search LuaSec sources." )
set ( OPENSSL_HOME "${PROJECT_SOURCE_DIR}/externals/openssl" CACHE PATH "Where to search OpenSSL sources." )

# C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\share\cmake-4.1\Modules\FindLua.cmake
set ( ENV{LUA_DIR} "${PROJECT_SOURCE_DIR}/externals/lua" )  # FindLua.cmake
find_package( Lua REQUIRED )
message( STATUS "Lua Version ${LUA_VERSION_STRING}" )
message( STATUS "Lua Includes ${LUA_INCLUDE_DIR}" )
message( STATUS "Lua Library ${LUA_LIBRARY}" )
message( STATUS "Lua Libraries ${LUA_LIBRARIES}" )


set ( SRC_SOCKET src/luasocket/buffer.c
        src/luasocket/io.c src/luasocket/timeout.c src/luasocket/wsocket.c )

set ( SRC_LUASEC
        src/config.c src/context.c src/ec.c
        src/options.c src/ssl.c src/x509.c )

# set ( INSTALL_SOURCES src/ssl.lua src/https.lua )


list( TRANSFORM SRC_SOCKET PREPEND "${LUASEC_HOME}/" )
list( TRANSFORM SRC_LUASEC PREPEND "${LUASEC_HOME}/" )


add_library ( luasocketobj OBJECT ${SRC_SOCKET} )
target_include_directories( luasocketobj PRIVATE ${LUA_INCLUDE_DIR} )
target_compile_definitions (luasocketobj PRIVATE
        # src\luasocket\buffer.c: buffer_meth_send, buffer_meth_receive
        # push time elapsed during operation as the last return value
        LUASOCKET_DEBUG
)

add_library ( luasecobj OBJECT ${SRC_LUASEC} )
target_include_directories( luasecobj PRIVATE ${OPENSSL_HOME}/include ${LUA_INCLUDE_DIR} ${LUASEC_HOME}/src )
# from src/luasec-1.3.2-1.rockspec : build['platforms']['windows']
target_compile_definitions ( luasecobj PRIVATE
    # src\ssl.c: luaopen_ssl_core
    # Initialize internal library : socket_open();
        WITH_LUASOCKET
    # src\x509.c: +inet_ntop -> getnameinfo
    # For WinXP (SP3), set the following preprocessor macros: LUASEC_INET_NTOP, WINVER=0x0501, _WIN32_WINNT=0x0501, NTDDI_VERSION=0x05010300
        LUASEC_INET_NTOP
        # WINVER=0x0501 _WIN32_WINNT=0x0501 NTDDI_VERSION=0x05010300
    #
    # BUFFER_DEBUG  # unused
    # LSEC_EXPORTS  # unused (?outdated)
    # LSEC_API="__declspec(dllexport)"  # unnecessary (+compiler warning, dropped)
    #
    # _USRDLL # ?? unused
    # WIN32 NDEBUG _WINDOWS
    #
        OPENSSL_API_COMPAT=0x10101000L
)


add_library( libluasecdll MODULE )
set_target_properties ( libluasecdll PROPERTIES OUTPUT_NAME ssl )
target_link_libraries ( libluasecdll PRIVATE
        luasecobj
        luasocketobj
        ${LUA_LIBRARY}
        ${OPENSSL_HOME}/lib/libssl.lib
        ${OPENSSL_HOME}/lib/libcrypto.lib
        ws2_32  # as string passes directly to linker
)

install ( TARGETS libluasecdll LIBRARY DESTINATION bin )
install ( FILES ${LUASEC_HOME}/src/ssl.lua DESTINATION bin )
install ( FILES ${LUASEC_HOME}/src/https.lua DESTINATION bin/ssl )
install ( FILES ${OPENSSL_HOME}/bin/libssl-3-x64.dll DESTINATION bin )
install ( FILES ${OPENSSL_HOME}/bin/libcrypto-3-x64.dll DESTINATION bin )
# install ( TARGETS libluasecdll RUNTIME_DEPENDENCIES DESTINATION bin )
