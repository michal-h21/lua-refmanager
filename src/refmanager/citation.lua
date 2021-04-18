kpse.set_program_name "luatex"
local bibtex = require "refmanager.bibtex"
local Citation = {
}

function Citation:new(entrytype, bibdata)
  local bibdata = bibdata or {}
  self.__index = self
  return setmetatable({bibdata = bibdata, entrytype = entrytype, current = {}, separator = ".", punctuation = "", space = " ", ignore_punct = true, formats = {} }, Citation)
end


function Citation:iffield(name)
  return self.bibdata[name]
end

-- add content to the current output array
function Citation:add_content(content)
  table.insert(self.current, content)
end

function Citation:print_separator()
  if not self.ignore_punct then
    self:add_content(self.separator)
    self:print_space()
  end
end

function Citation:print_space()
  self:add_content(self.space)
end

function Citation:set_space(space)
  self.space = space
end

function Citation:print_punct()
  if self.punctuation~="" then
    self:add_content(self.punctuation)
    self:print_space()
  end
  self.punctuation = ""
end

function Citation:add_punct(punct)
  if not self.ignore_punct then
    self.punctuation = punct
  end
end

function Citation:set_format(field,format)
  self.formats[field] = format
end

function Citation:get_format(name)
  local format = self.formats[name] or "%s"
  return string.format(format, bibtex.decode(self.bibdata[name]))
end

function Citation:print_field(name)
  if self.bibdata[name] then
    self:print_punct()
    local format = self:get_format(name)
    self:add_content(format)
    self.ignore_punct = false
  else
    self.ignore_punct = true
    -- self.punctuation = ""
  end
end

function Citation:finish()
  self:add_content(self.separator)
end

function Citation:new_unit()
  self.punctuation = ""
  self:print_separator()
end

function Citation:format()
  local formated =  table.concat(self.current):gsub("%.+", "."):gsub(",%.", "."):gsub("%s+", " ")
  return formated
end

local function book(data)
  local test = Citation:new ( "book",  data)
  test:print_field("author")
  test:new_unit()
  test:print_field("title")
  test:new_unit()
  test:print_field("location")
  test:add_punct(":")
  test:print_field("publisher")
  test:add_punct(",")
  test:print_field("year")
  test:finish()
  return test
end

local function article(data)
  local test = Citation:new ( "book",  data)
  test:print_field("author")
  test:set_format("volume", "vol. %s")
  test:set_format("number", "no. %s")
  test:set_format("pages", "p. %s")
  test:new_unit()
  test:print_field("title")
  test:new_unit()
  test:print_field("journal")
  test:new_unit()
  test:print_field("year")
  test:add_punct(",")
  test:print_field("volume")
  test:add_punct(",")
  test:print_field("number")
  test:add_punct(",")
  test:print_field("pages")
  test:finish()
  return test
end
local test = book({author="Josef Novák", title="Sample book", publisher="Grada", location="Praha", year="2021"})


print(test:format())

local samplef = io.open(kpse.find_file("biblatex-examples.bib","bib"), "r")
local sample = samplef:read("*all")
samplef:close()

-- sample = [[
-- @article{pokus,
-- title = "ahoj",
-- author = "ja"
-- }]]
-- local x = lpegmatch(grammar, sample)
local newentries = bibtex.parse(sample)

for _, entry in ipairs(newentries) do
  if entry.tag == "@book" then
    local citation = book(entry.fields)
    print(citation:format())
  elseif entry.tag == "@article" then
    local citation = article(entry.fields)
    print(citation:format())
  end
  -- print "=============="
  -- print(entry.tag, entry.key)
  -- print "--------------"
  -- for k,v in pairs(entry.fields) do
    -- print(k,v)
  -- end
end
