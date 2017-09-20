local datafile = require "datafile"

local loader = {}

local function load_modules(cachefile)
  local cachefile = cachefile or "data/test.txt"
  local f, status = datafile.open(cachefile, "r")
  print(f, status)
  local f, status = datafile.open(cachefile, "r", "config")
  print(f, status)
  local f, status = datafile.open(cachefile, "r", "cache")
  print(f, status)
end

local cache = load_modules()

local function get_module(id)
end


loader.get_module = get_module

return loader
