-- local scanner = require "web_sanitize.query"
local html = require "htmlparser"
local http_request = require "http.request"
local iconv = require "iconv"
local zlib = require "zlib"
local url = arg[1] or "http://bair.berkeley.edu/blog/2017/07/18/learning-to-learn/"
local request = http_request.new_from_uri(url)
request.headers:append("Accept-Charset", "UTF-8")
-- request.headers:append("Accept-Encoding", "identity;q=1.0")
for name, value in request.headers:each() do
  -- print("header", name, value)
end
local headers, stream = assert(request:go())
local body = assert(stream:get_body_as_string())
if headers:get ":status" ~= "200" then
  error(body)
end
-- print(body)

local contenttype = headers["content-type"]
local encoding
for k,v in pairs(headers) do
  -- print("headers", "#"..k.."#",v)
  if k=="content-type" then
    contenttype = v
  elseif k == "content-encoding" then
    encoding = v
  end
end

-- handle gzip compressed
if encoding then
  if encoding == "gzip" then
    -- print("decompress", body:len())
    local f = io.open("juj.gz", "w")
    f:write(body)
    f:close()
    local gzipsream  = zlib.inflate(body)
    local t = {}
    for line in  gzipsream:lines() do
      t[#t+1] = line
    end
    gzipsream:close()
    body = table.concat(t, "\n")
    -- print(body)
  end
end

if contenttype then
  local charset = contenttype:match("charset=(.+)")
  print("contenttype", contenttype,charset)
  if charset and charset:lower() ~= "utf-8" then
    local cd =  iconv.new("utf8", charset)
    if cd then
      body = cd:iconv(body)
    else
      print("can't open iconv for " ..charset)
    end
  end
else
  print("no content type", contenttype)
end

  

-- for chunk in stream:each_chunk() do
--   print(chunk)
-- end


-- local p = [[
-- <html>
-- <head><title>pokus</title></head>
-- </head>
-- ]]

local function get_meta(dom, attr_name, value)
  local selected = dom:select("meta["..attr_name .."='"..value .. "']")
  if selected and type(selected) == "table" and #selected > 0 then
    return value, selected[1].attributes["content"]
  end
  return value, nil
end

local function get_meta_name(dom,name)
  return get_meta(dom, "name", name)
end

local function get_meta_property(dom, property)
  return get_meta(dom, "property", property)
end

htmlparser_looplimit=1000009
local dom,msg = html.parse(body)
print("parse status", msg, errorsparse)

local j = dom:select("head title")
-- local j = dom:select("script")

for k,v in ipairs(j) do
  print("record", k)
  -- for x,y in pairs(v) do
  --   print(x,y)
  -- end
  -- for x,y in pairs(v.attr or {}) do
  --   print("attr", x,y)
  -- end
  print("text: ",v:getcontent())
  -- print(p:sub(v.inner_pos, v.end_inner_pos-1))
end


print(get_meta_name(dom, "author"))
print(get_meta_property(dom, "og:site_name"))
print(get_meta_property(dom, "og:type"))
print(get_meta_property(dom, "og:title"))
print(get_meta_property(dom, "og:description"))

local j = dom:select("meta[property]")

for _, v in ipairs(j) do
  print(get_meta_property(dom, v.attributes.property))
end
