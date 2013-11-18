describe "Filter tests", () ->

  beforeEach module "appFltr"

  describe "truncate filter unit tests", () ->

    it "should correctly truncate output", inject (truncateFilter) ->
      expect(truncateFilter('123456789012345678901', 5).length).toBe(5)

    it "should correctly add truncation chars at the end", inject (truncateFilter) ->
      expect(truncateFilter('123456', 4)).toBe("1...")
