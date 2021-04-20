local bibtex = require "refmanager.bibtex"
describe("BibTeX parsing", function()
  local data = [[

@string{jomch   = {J.~Organomet. Chem.}}
@article{aksin,
  author       = {Aks{\i}n, {\"O}zge and T{\"u}rkmen, Hayati and Artok, Levent
                  and {\c{C}}etinkaya, Bekir and Ni, Chaoying and
                  B{\"u}y{\"u}kg{\"u}ng{\"o}r, Orhan and {\"O}zkal, Erhan},
  title        = {Effect of immobilization on catalytic characteristics of
                  saturated {Pd-N}-heterocyclic carbenes in {Mizoroki-Heck}
                  reactions},
  journaltitle = jomch,
  date         = 2006,
  volume       = 691,
  number       = 13,
  pages        = {3027-3036},
  indextitle   = {Effect of immobilization on catalytic characteristics},
}
  ]]

  local entries = bibtex.parse(data)
  it("should parse bibtex data", function()
    assert.are.equals(#entries, 1)
    local entry = entries[1]
    assert.are.equals(entry.tag, "@article")
    assert.are.equals(entry.key, "aksin")
    local fields = entry.fields
    assert.are.equals(fields.journaltitle, "J.~Organomet. Chem.")
    
  end)
end)

describe("BibTeX functions", function()
  it("Should decode accents", function()
    assert.are.equals(bibtex.decode("Aks{\\i}n, {\\\"O}zge and T{\\\"u}rkmen"), "Aksın, Özge and Türkmen")
    assert.are.equals(bibtex.decode("Hello \\textit{world}"), "Hello world")
  end)
  it("Should split lists", function()
    local no_split = bibtex.parse_list("William Reid {and} Company")
    assert.are.equals(#no_split, 1)
    assert.are.equals(no_split[1], "William Reid {and} Company")
    local split = bibtex.parse_list("American Society for Photogrammetry {and} Remote Sensing and American Congress on Surveying {and} Mapping")
    assert.are.equals(#split, 2)
    assert.are.equals(split[1],"American Society for Photogrammetry {and} Remote Sensing")
    local split = bibtex.parse_list("{American Society for Photogrammetry and Remote Sensing} and {American Congress on Surveying and Mapping}")
    assert.are.equals(#split, 2)
    assert.are.equals(split[1],"{American Society for Photogrammetry and Remote Sensing}")
  end)
end)
