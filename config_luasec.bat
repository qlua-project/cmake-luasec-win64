:: see src/INSTALL
::
:: * OpenSSL options:
::     By default, this version includes options for OpenSSL 3.0.8
::     If you need to generate the options for a different version of OpenSSL:
::       $ cd src
::       $ lua options.lua -g /usr/include/openssl/ssl.h [version] > options.c
::

@echo off

pushd %~dp0src\src

:: externals\openssl\include\openssl\opensslv.h
::     # define OPENSSL_VERSION_STR "3.5.0"
::     # define OPENSSL_FULL_VERSION_STR "3.5.0-dev"

"%~dp0externals\lua\bin\lua" options.lua -g "%~dp0externals\openssl\include\openssl\ssl.h" "3.5.0-dev" > options.c

popd
