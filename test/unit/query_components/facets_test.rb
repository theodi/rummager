require "test_helper"
require "unified_search_builder"

class FacetsTest < ShouldaUnitTestCase
  context "search with facet" do
    should "have correct facet in payload" do
      builder = QueryComponents::Facets.new(search_query_params(
        facets: { "organisations" => { requested: 10, scope: :exclude_field_filter } },
      ))

      result = builder.payload

      assert_equal(
        {
          "organisations" => {
            terms: {
              field: "organisations",
              order: "count",
              size: 100000,
            },
          },
        },
        result
      )
    end
  end

  context "search with facet and filter on same field" do
    setup do
      @builder = QueryComponents::Facets.new(
        filters: [ text_filter("organisations", ["hm-magic"]) ],
        facets: {"organisations" => {requested: 10, scope: :exclude_field_filter}},
      )
    end

    should "have correct facet in payload" do
      assert_equal(
        {
          "organisations" => {
            terms: {
              field: "organisations",
              order: "count",
              size: 100000,
            },
          },
        },
        @builder.payload)
    end
  end

  context "search with facet and filter on same field, and scope set to all_filters" do
    setup do
      @builder = QueryComponents::Facets.new(
        filters: [ text_filter("organisations", ["hm-magic"]) ],
        facets: {"organisations" => {requested: 10, scope: :all_filters}},
      )
    end

    should "have correct facet in payload" do
      assert_equal(
        {
          "organisations" => {
            terms: {
              field: "organisations",
              order: "count",
              size: 100000,
            },
            facet_filter: {
              "terms" => {"organisations" => ["hm-magic"]}
            },
          },
        },
        @builder.payload)
    end
  end

  context "search with facet and filter on different field" do
    setup do
      @builder = QueryComponents::Facets.new(
        filters: [ text_filter("section", "levitation") ],
        facets: {"organisations" => {requested: 10, scope: :exclude_field_filter}},
      )
    end

    should "have facet with facet_filter in payload" do
      assert_equal(
        {
          "organisations" => {
            terms: {
              field: "organisations",
              order: "count",
              size: 100000,
            },
            facet_filter: {
              "terms" => {"section" => ["levitation"]}
            },
          },
        },
        @builder.payload)
    end
  end

  def text_filter(field_name, values, reject = false)
    SearchParameterParser::TextFieldFilter.new(field_name, values, reject)
  end
end
