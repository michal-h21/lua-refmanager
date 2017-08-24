kpse.set_program_name "luatex"

require "lualibs"
xml = {finalizers= {}}
lxml = {}
characters = {data = {}, tex= {}}
require "lualibs-util-str"
lpeg.patterns.xml = {}
lpeg.patterns.xml.escape = lpeg.patterns.xmlescape

require "bibl-bib"



-- test
local samplef = io.open(kpse.find_file("IEEEexample.bib","bib"), "r")
local sample = samplef:read("*all")
samplef:close()

-- sample = [[
-- @article{pokus,
-- title = "ahoj",
-- author = "ja"
-- }]]
local x = lpeg.match(grammar, sample)

for k,v in pairs(data) do 
  print(k,v)
  for x,y in pairs(v) do
    print(x,y)
    for j,h in pairs(y) do
      print(j,h)
    end
  end
end
