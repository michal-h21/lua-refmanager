package = "lua-refmanager"
version = "0.1.0-1"
source = {
  url = "https://github.com/michal-h21/lua-refmanager/archive/v0.1.0.tar.gz",
  dir = "lua-refmanager-0.1.0-1"
}
description = {
  summary = "lua-refmanager",
  detailed = [[
    Command line bibliography manager
  ]],
  homepage = "https://github.com/michal-h21/lua-refmanager/",
  license = "MIT <http://opensource.org/licenses/MIT>"
}
dependencies = {
  "lua >= 5.1",
  "htmlparser",
  "lua-iconv",
  "lua-zlib",
  "argparse",
  "html-entities",
  "date",
  -- "datafile",
  "dkjson",
  "lpeg",
  "luasocket",
  "luasec",
  -- "http",
}
build = {
  type = "none",
  install = {
    lua = {
      ["refmanager.tidy"] = "src/refmanager/tidy.lua",
      ["refmanager.html"] = "src/refmanager/html.lua",
      ["refmanager.http"] = "src/refmanager/http.lua",
      ["refmanager.loader"] = "src/refmanager/loader.lua",
      ["refmanager.logging"] = "src/refmanager/logging.lua",
      ["refmanager.bibtex"] = "src/refmanager/bibtex.lua",
      ["refmanager.citation"] = "src/refmanager/citation.lua",
      ["refmanager.texaccents"] = "src/refmanager/texaccents.lua",
    },
    bin = {
      ["luarefmanager"] = "src/refmanager.lua",
    }
  },
  -- copy_directories = {"data"}
}
