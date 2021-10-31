-- local http_request = require "http.request"
local logging = require "refmanager.logging"
local http    = require "socket.http"
local https   = require "ssl.https"
local iconv   = require "iconv"
local zlib    = require "zlib"
-- local url = arg[1] or "http://bair.berkeley.edu/blog/2017/07/18/learning-to-learn/"

local log = logging.new("http")

-- request object
local Request = {}
Request.__index = Request

function Request.new(uri, method)
  local self = setmetatable({}, Request)
  self.headers = {
    ["accept-charset"] = "UTF-8"
  }

  self.method = method or "GET"

  -- use correct library for https
  if uri:match("^https") then
    self.request = https
  else
    self.request = http
  end
  self.uri = uri
  return self
end

function Request.set_header(self, header, value)
  self.headers[header] = value
end

function Request.set_source(self, source)
  -- 
  if type(source) == "string" then
    self.source = ltn12.source.string(source)
    self:set_header("Content-Length", source:len())
  end
end

function Request.go(self)
  local request = self.request
  local resp = {}
  success, status, headers, s = request.request{
    url = self.uri,
    headers = self.headers,
    method = self.method,
    source = self.source,
    sink = ltn12.sink.table(resp),
  }
  self.status = status
  self.message = s
  -- test if everything worked correctly
  if not success  then
    log:error("Cannot connect to " .. self.uri)
    log:error("Message: " .. status)
    return self
  elseif status > 299 then -- maybe we could support 3xx statuses in the future?
    log:error("Cannot connect to " .. self.uri)
    log:error("Status code: " .. status)
    return self 
  end
  self.headers = headers
  self.raw_body = table.concat(resp) -- self.stream:get_body_as_string()
  -- 
  self:fix_encoding()
  self:fix_charset()
  return self
end

function Request.get_status(self)
  return self.status
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
  local encoding = headers["content-encoding"]
  if encoding and encoding ==  "gzip" then
    local body = self:get_body()
    local gzipsream  = zlib.inflate()
    local newbody = gzipsream(body)
    self:save_body(newbody)
  end
end


function Request.fix_charset(self)
  local headers = self.headers
  local contenttype = headers["content-type"]
  if contenttype then
    local charset = contenttype:match("charset=(.+)")
    if charset and charset:lower() ~= "utf-8" then
      local body = self:get_body()
      local cd =  iconv.new("utf8", charset)
      if cd then
        self:save_body(cd:iconv(body))
      else
        -- ToDo: handle error if iconv for that charset isn't available
      end
    end
  end

end





return Request
