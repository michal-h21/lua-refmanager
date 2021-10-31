local http = require "refmanager.http"
local zotero = {}

local zotero_endpoint = "http://127.0.0.1:1969"

function zotero.get_json(url)
  -- first we need to get a Zotero JSON data for a URL
  local json_endpoint = zotero_endpoint .. "/web"
  -- URL should be send using POST
  local request = http.new(json_endpoint,"POST")
  request:set_header('Content-Type', 'text/plain')
  request:set_source(url)
  request:go()
  return request:get_body(), request
end

function zotero.get_biblatex(json_string)
  local biblatex_endpoint = zotero_endpoint .. "/export?format=biblatex"
  local request = http.new(biblatex_endpoint, "POST")
  request:set_header("Content-Type","application/json")
  request:set_source(json_string)
  request:go()
  return request:get_body(), request
end


local url = arg[1] or "https://www.nytimes.com/2018/06/11/technology/net-neutrality-repeal.html"
local request = http.new(url)
request:go()


print(request.status)
print(request.message)
for k,v in pairs(request.headers) do
  print(k, v)
end
print(request:get_body())
local json = zotero.get_json(url)
local biblatex = zotero.get_biblatex(json)
print(json)
print(biblatex)



return zotero 
