local http_request = require "http.request"
local iconv = require "iconv"
local zlib = require "zlib"
-- local url = arg[1] or "http://bair.berkeley.edu/blog/2017/07/18/learning-to-learn/"

-- request object
local Request = {}
Request.__index = Request

function Request.new(uri)
  local self = setmetatable({}, Request)
  -- create http request
  local request = http_request.new_from_uri(uri)
  request.headers:append("accept-charset", "UTF-8")
  self.request = request
  self.uri = uri
  return self
end

function Request.go(self)
  local request = self.request
  self.headers, self.stream = assert(request:go())
  self.status = self:get_status()
  self.body   = self.stream:get_body_as_string()
  self:encoding()
  return self
end

function Request.get_status(self)
  local headers = self.headers
  if headers then
    return tonumber(headers:get ":status")
  end
  return false
end

function Request.encoding(self)
  local headers = self.headers
  local contenttype = headers["content-type"]
  print(contenttype)
end

return Request


-- local body = assert()
-- if  then
--   error(body)
-- end
-- -- print(body)

-- local contenttype = headers["content-type"]
-- local encoding
-- for k,v in pairs(headers) do
--   -- print("headers", "#"..k.."#",v)
--   if k=="content-type" then
--     contenttype = v
--   elseif k == "content-encoding" then
--     encoding = v
--   end
-- end

-- -- handle gzip compressed
-- if encoding then
--   if encoding == "gzip" then
--     -- print("decompress", body:len())
--     local f = io.open("juj.gz", "w")
--     f:write(body)
--     f:close()
--     local gzipsream  = zlib.inflate(body)
--     local t = {}
--     for line in  gzipsream:lines() do
--       t[#t+1] = line
--     end
--     gzipsream:close()
--     body = table.concat(t, "\n")
--     -- print(body)
--   end
-- end

-- if contenttype then
--   local charset = contenttype:match("charset=(.+)")
--   print("contenttype", contenttype,charset)
--   if charset and charset:lower() ~= "utf-8" then
--     local cd =  iconv.new("utf8", charset)
--     if cd then
--       body = cd:iconv(body)
--     else
--       print("can't open iconv for " ..charset)
--     end
--   end
-- else
--   print("no content type", contenttype)
-- end
