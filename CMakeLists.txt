cmake_minimum_required ( VERSION 3.30 )
project (luasec VERSION 1.3.2.1 LANGUAGES C)

include ( CMakePrintHelpers )

add_compile_options( /W4 )  # -Wall

set ( LUASEC_HOME src CACHE PATH "Where to search LuaSec sources." )
set ( LUA_HOME "externals/lua" CACHE PATH "Where to search Lua sources." )
set ( OPENSSL_HOME "externals/openssl" CACHE PATH "Where to search OpenSSL sources." )

set ( SRC_LIB src/luasocket/buffer.c
        src/luasocket/io.c src/luasocket/timeout.c src/luasocket/wsocket.c )
list( TRANSFORM SRC_LIB PREPEND "${LUASEC_HOME}/" )

add_library ( libluasocket STATIC ${SRC_LIB} )
set_target_properties ( libluasocket PROPERTIES OUTPUT_NAME luasocket )
target_include_directories( libluasocket PRIVATE ${LUA_HOME}/include )

set ( SRC_CORE
        src/config.c src/context.c src/ec.c
        src/options.c src/ssl.c src/x509.c )
list( TRANSFORM SRC_CORE PREPEND "${LUASEC_HOME}/" )

set ( INSTALL_SOURCES src/ssl.lua src/https.lua )

add_library ( luasecobj OBJECT ${SRC_CORE} )
target_include_directories( luasecobj PRIVATE ${OPENSSL_HOME}/include ${LUA_HOME}/include ${LUASEC_HOME}/src )
# from src/luasec-1.3.2-1.rockspec
target_compile_definitions (luasecobj PUBLIC
    WITH_LUASOCKET
    # LUASOCKET_DEBUG
    # BUFFER_DEBUG
    LSEC_EXPORTS  # unused (?outdated)
    # LSEC_API="__declspec(dllexport)"  # unnecessary (+compiler warning, dropped)
    LUASEC_INET_NTOP
    _USRDLL # ??
    # WIN32 NDEBUG _WINDOWS
    # WINVER=0x0501 _WIN32_WINNT=0x0501 NTDDI_VERSION=0x05010300
)

#add_library ( libluasec STATIC $<TARGET_OBJECTS:luasecobj> )
#set_target_properties ( libluasec PROPERTIES OUTPUT_NAME ssl )

add_library ( libluasecdll SHARED $<TARGET_OBJECTS:luasecobj> )
set_target_properties ( libluasecdll PROPERTIES OUTPUT_NAME ssl )
target_link_libraries ( libluasecdll
        ${PROJECT_SOURCE_DIR}/${LUA_HOME}/lib/lua54.lib
        ${PROJECT_SOURCE_DIR}/${OPENSSL_HOME}/lib/libssl.lib
        ${PROJECT_SOURCE_DIR}/${OPENSSL_HOME}/lib/libcrypto.lib
        libluasocket
        ws2_32 )

install ( TARGETS libluasecdll RUNTIME )
install ( FILES ${LUASEC_HOME}/src/ssl.lua DESTINATION shared )
install ( FILES ${LUASEC_HOME}/src/https.lua DESTINATION shared/ssl )
