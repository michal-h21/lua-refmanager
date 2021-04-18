-- kpse.set_program_name "luatex"

-- This is a basic BibTeX parser. It is based on an older version of ConTeXt code. 
-- See `kpsewhich bibl-bib.lua` 
--
local accents = require "refmanager.texaccents"

local lower, format, gsub, concat = string.lower, string.format, string.gsub, table.concat
local lpegmatch = lpeg.match


local P, R, S, C, Cc, Cs, Ct, V = lpeg.P, lpeg.R, lpeg.S, lpeg.C, lpeg.Cc, lpeg.Cs, lpeg.Ct, lpeg.V


local bibtex = bibtex or {}


local defaultshortcuts = {
    jan = "1",
    feb = "2",
    mar = "3",
    apr = "4",
    may = "5",
    jun = "6",
    jul = "7",
    aug = "8",
    sep = "9",
    oct = "10",
    nov = "11",
    dec = "12",
}

local shortcuts = { }
local entries = {}

-- Currently we expand shortcuts and for large ones (like the acknowledgements
-- in tugboat.bib this is not that efficient. However, eventually strings get
-- hashed again.

local function do_shortcut(tag,key,value)
  if lower(tag) == "@string" then
    shortcuts[key] = value
  end
end

-- tag = entry type
-- key = entry ID
-- tab = array with entry fields
local function do_definition(tag,key,tab) 
  local t = { }
  for i=1,#tab,2 do
    t[tab[i]] = tab[i+1]
  end
  table.insert(entries, {
    tag = tag,
    key = key,
    fields = t
  })
    -- end
end

local function resolve(s)
    return shortcuts[s] or defaultshortcuts[s] or s -- can be number
end

local percent    = P("%")
local start      = P("@")
local comma      = P(",")
local hash       = P("#")
local escape     = P("\\")
local single     = P("'")
local double     = P('"')
local left       = P('{')
local right      = P('}')
local both       = left + right
local lineending = S("\n\r")
local space      = S(" \t\n\r\f")
local spacing    = space^0
local equal      = P("=")
local collapsed  = (space^1)/ " "

----- function add(a,b) if b then return a..b else return a end end

local keyword    = C((R("az","AZ","09") + S("@_:-"))^1)  -- C((1-space)^1)
local s_quoted   = ((escape*single) + collapsed + (1-single))^0
local d_quoted   = ((escape*double) + collapsed + (1-double))^0
local balanced = P {
    [1] = ((escape * (left+right)) + (1 - (left+right)) + V(2))^0,
    [2] = left * V(1) * right
}

local s_value    = (single/"") * s_quoted * (single/"")
local d_value    = (double/"") * d_quoted * (double/"")
local b_value    = (left  /"") * balanced * (right /"")
local r_value    = keyword/resolve

local somevalue  = s_value + d_value + b_value + r_value
local value      = Cs((somevalue * ((spacing * hash * spacing)/"" * somevalue)^0))

local assignment = spacing * keyword * spacing * equal * spacing * value * spacing
local shortcut   = keyword * spacing * left * spacing * (assignment * comma^0)^0 * spacing * right
local definition = keyword * spacing * left * spacing * keyword * comma * Ct((assignment * comma^0)^0) * spacing * right
local comment    = keyword * spacing * left * (1-right)^0 * spacing * right
local forget     = percent^1 * (1-lineending)^0

-- todo \%

local grammar = (space + forget + shortcut/do_shortcut + definition/do_definition + comment + 1)^0

-- this is just shallow copy. as the entries are not deeply nested and don't contain any metatables, it should suffice
local function copy(tbl)
  local newtbl = {}
  for k,v in pairs(tbl) do newtbl[k] = v end
  return newtbl
end

function bibtex.parse(text)
  entries = {}
  lpegmatch(grammar, text)
  -- we don't want to overried the returned table by subsequent calls to this function
  return copy(entries)
end


-- convert TeX accents to Unicode and remove unnecessary brackets
function bibtex.decode(text)
  -- remove accents
  local text = text:gsub("(\\.){(.-)}", "%1 %2")
  text = text:gsub("{%s*(\\[^\\]+)}", accents)
  -- expand \& etc
  text = text:gsub("\\(%A)", "%1")
  -- try to remove other known commands
  text = text:gsub("(\\%w+)", accents)
  -- remove TeX commands with arguments
  text = text:gsub("\\.-(%b{})", function(a)
    return a:sub(2, -2)
  end)
  -- remove brackets that are still here
  text = text:gsub("{(.-)}", "%1")

  -- expand 

  return text

end



-- print(bibtex.decode([[Die Geburt der {\v c}{\v{e}} Trag{\"o}die. Unzeitgem{\"a}{\ss}e Betrachtungen I--IV. Nachgelassene Schriften 1870--1973. M{\"u}nchen. Bronis{\l}aw. Artemis \& Winkler.]]))


return bibtex
