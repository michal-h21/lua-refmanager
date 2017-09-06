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
  self.raw_body   = self.stream:get_body_as_string()
  self:fix_encoding()
  self:fix_charset()
  return self
end

function Request.get_status(self)
  local headers = self.headers
  if headers then
    return tonumber(headers:get ":status")
  end
  return false
end

function Request.get_body(self)
  return self.body or self.raw_body
end


function Request.save_body(self,body)
  self.body = body
end

function Request.fix_encoding(self)
  -- handle gzipped content
  local headers = self.headers
  local encoding = headers:get "content-encoding"
  if encoding and encoding ==  "gzip" then
    local body = self:get_body()
    local gzipsream  = zlib.inflate()
    local newbody = gzipsream(body)
    self:save_body(newbody)
    -- print(body)
  end
end


function Request.fix_charset(self)
  local headers = self.headers
  local contenttype = headers:get "content-type"
  if contenttype then
    local charset = contenttype:match("charset=(.+)")
    print("contenttype", contenttype,charset)
    if charset and charset:lower() ~= "utf-8" then
      local body = self:get_body()
      local cd =  iconv.new("utf8", charset)
      if cd then
        self:save_body(cd:iconv(body))
      else
        -- ToDo: handle error if iconv for that charset isn't available
        -- print("can't open iconv for " ..charset)
      end
    end
    -- print("no content type", contenttype)
  end

end





return Request
