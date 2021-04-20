kpse.set_program_name "luatex"
local bibtex = require "refmanager.bibtex"
local Citation = {
}


local uchar = utf8.char
function Citation:new(entrytype, bibdata)
  local bibdata = bibdata or {}
  self.__index = self
  local uppercases = bibtex.uppercases
  local lowercases = bibtex.lowercases
  return setmetatable({
    bibdata = bibdata, entrytype = entrytype, current = {}, separator = ".", punctuation = "", 
    space = " ", ignore_punct = true, formats = {}, printed_fields=0 ,
    lowercases=lowercases, uppercases = uppercases
  }, Citation)
end


function Citation:iffield(name)
  return self.bibdata[name]
end

-- add content to the current output array
function Citation:add_content(content)
  table.insert(self.current, content)
end

function Citation:print_separator()
  if self.printed_fields > 0 then
    self:add_content(self.separator)
    self:print_space()
  end
  self.printed_fields = 0
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


local ucodes = utf8.codes
function Citation:make_initial(text)
  local out = {}
  -- loop over utf-8 codepoints of the text, initialize the first
  for pos, code in ucodes(text) do
    if pos == 1 then
      -- try to find the uppercase for this character
      code = self.uppercases[code] or code
    end
    out[#out+1] = uchar(code)
  end
  return table.concat(out)
end


function Citation:add_text(text)
  -- make initial for every text after new unit
  if self.printed_fields == 0 then
    text = self:make_initial(text)
  end
  self:add_content(text)
  self.ignore_punct = false
  self.printed_fields = self.printed_fields + 1
end

function Citation:print_field(name)
  if self.bibdata[name] then
    self:print_punct()
    local format = self:get_format(name)
    self:add_text(format)
  else
    self.ignore_punct = true
    -- self.punctuation = ""
  end
end

function Citation:finish()
  self:print_separator()
end

function Citation:new_unit()
  self.punctuation = ""
  self:print_separator()
end

function Citation:format()
  local formated =  table.concat(self.current):gsub("%.+", "."):gsub(",%.", "."):gsub("%s+", " ")
  return formated
end

--- something like bibmacro in biblatex
local function print_title(self,name)
  -- use empty string for the "title" field, "journal" for "journaltitle" etc.
  self:print_field(name .. "title")
  local subtitle = name .. "subtitle"
  if self:iffield(subtitle) then
    self:add_punct(":")
    self:print_field(subtitle)
  end
end


local function book(data)
  local test = Citation:new ( "book",  data)
  test:set_format("isbn", "ISBN %s")
  test:print_field("author")
  test:new_unit()
  -- test:print_field("title")
  -- test:add_punct(":")
  -- test:print_field("subtitle")
  print_title(test,"")
  test:new_unit()
  test:print_field("location")
  test:add_punct(":")
  test:print_field("publisher")
  test:add_punct(",")
  test:print_field("year")
  test:new_unit()
  test:print_field("isbn")
  test:finish()
  return test
end

local function article(data)
  local test = Citation:new ( "book",  data)
  test:print_field("author")
  test:set_format("volume", "vol. %s")
  test:set_format("number", "no. %s")
  test:set_format("pages", "p. %s")
  test:set_format("issn", "ISSN %s")
  test:new_unit()
  print_title(test,"")
  test:new_unit()
  print_title(test,"journal")
  -- test:print_field("journaltitle")
  -- test:add_punct(":")
  -- test:print_field("journalsubtitle")
  test:new_unit()
  test:print_field("year")
  test:add_punct(",")
  test:print_field("volume")
  test:add_punct(",")
  test:print_field("number")
  test:add_punct(",")
  test:print_field("pages")
  test:new_unit()
  test:print_field("issn")
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

