require "test_helper"
require "unified_search_builder"

class TextQueryTest < ShouldaUnitTestCase
  context "search with debug disabling use of synonyms" do
    should "use the all_searchable_text.synonym field" do
      builder = QueryComponents::TextQuery.new(search_query_params)

      query = builder.payload

      assert_match(/all_searchable_text.synonym/, query.to_s)
    end

    should "not use the all_searchable_text.synonym field" do
      builder = QueryComponents::TextQuery.new(search_query_params(debug: { disable_synonyms: true }))

      query = builder.payload

      refute_match(/all_searchable_text.synonym/, query.to_s)
    end
  end
end
