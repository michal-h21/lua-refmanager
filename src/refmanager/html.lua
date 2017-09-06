-- local scanner = require "web_sanitize.query"
local html = require "htmlparser"
local http = require "refmanager.http"
local url = arg[1] or "http://bair.berkeley.edu/blog/2017/07/18/learning-to-learn/"



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

htmlparser_looplimit=100009
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
