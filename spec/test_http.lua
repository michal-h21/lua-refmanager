expose("Test http connection", function() 
  local http = require "refmanager.http"
  it("should be loaded", function()
    assert.truthy(type(http) == "table")
  end)
  describe("basic tests", function()
    local request = http.new("https://www.root.cz/")
    request:go()
    it("requests should work", function()
      assert.are.equal(request:get_status(), 200)
      
    end)
    local origbody = request:get_body()
    it("body should be string", function()
      assert.are.equal(type(origbody), "string")
    end)
  end)



end)
