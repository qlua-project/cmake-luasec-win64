package = "cmake-luasec-win64"
version = "dev-1"
source = {
   url = "git+ssh://git@github.com/qlua-project/cmake-luasec-win64.git",
   tag = "v1-scm-5.4.1",
}
supported_platforms = {
    "win32",
}
dependencies = {
   "lua ~> 5.4",
}
build = {
   type = "builtin",
   platforms = {
      windows = {
         install = {
            lib = {
               "bin/ssl.dll",  
            },
            lua = {
               "bin/ssl.lua",
               ['ssl.https'] = "bin/ssl/https.lua",
            }
         },
         modules = {},
      },
   },
}
