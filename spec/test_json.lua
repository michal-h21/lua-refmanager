local json = require "dkjson"
local html = require "refmanager.html"

json.use_lpeg ()

local json_data = io.read("*all")

local decoded, status = json.decode(json_data)

if not status then
  print "decoding error"
  print(json_data)
else
  for k,v in pairs(decoded) do
    print(k,v)
  end
end
