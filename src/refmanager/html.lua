--- HTML handling library for Refmanager
-- @classmod refmanager.html
-- @author Michal Hoftich
--
local tidy = require "refmanager.tidy"
local http = require "refmanager.http"
local htmlparser = require "htmlparser"
local io = require "io"


local Html = {}
Html.__index = Html

--- Creates new Html object
-- @tparam[opt] string body HTML string to be processed
-- @return Html
function Html.new(body)
  local self = setmetatable({}, Html)
  self.origbody = body
  return self
end


--- @type Html
-- Remove the current document from memory, prepare for loading of another one
function Html:reset()
  self.body = nil
  self.url_address  = nil
  self.dom  = nil
  return self
end

--- Load HTML document from an URL
-- @param url URL of the HTML page to be loaded
function Html:url(url)
  local www = http.new(url)
  www:go()
  if www:get_status() == 200 then
    self:reset()
    self.url_address = url
    local body = www:get_body()
    self.origbody = body
  end
  return self
end

function Html:file(filename)
  local f = io.open(filename, "r")
  if f then
    local body = f:read("*all")
    f:close()
    self:reset()
    self.origbody = body
  end
  return self
end

function Html:string(str)
  self:reset()
  self.origbody = str
  return self
end

function Html:set_body(body)
  self.body = body
  return self
end

function Html:get_body()
  self.body = self.body or self.origbody
  return self.body
end

function Html:tidy(options)
  local body = self:get_body()
  local result = tidy.tidy(body, options)
  if result and result:len() > 0 then self:set_body(result) end
  return self
end

function Html:strip_comments()
  local body = self:get_body()
  self:set_body(tidy.strip_comments(body))
  return self
end

function Html:strip_scripts()
  local body = self:get_body()
  self:set_body(tidy.strip_scripts(body))
  return self
end

function Html:clean()
  self:tidy():strip_comments():strip_scripts()
  return self
end

function Html:get_dom()
  local dom = self.dom
  if not dom then
    local body = self:get_body()
    dom = htmlparser.parse(body) 
    self.dom = dom
  end
  return dom
end



return Html
