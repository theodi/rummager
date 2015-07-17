require "test_helper"
require "unified_search_builder"

class FilterTest < ShouldaUnitTestCase

  def text_filter(field_name, values)
    SearchParameterParser::TextFieldFilter.new(field_name, values, false)
  end

  def reject_filter(field_name, values)
    SearchParameterParser::TextFieldFilter.new(field_name, values, true)
  end

  def make_date_filter_param(field_name, values)
    SearchParameterParser::DateFieldFilter.new(field_name, values, false)
  end

  context "search with one filter" do
    should "append the correct text filters" do
      builder = QueryComponents::Filter.new(
        filters: [ text_filter("organisations", ["hm-magic"]) ]
      )

      result = builder.payload

      assert_equal(
        result,
        { "terms" => {"organisations" => ["hm-magic"] }}
      )
    end

    should "append the correct date filters" do
      builder = QueryComponents::Filter.new(
        filters: [ make_date_filter_param("field_with_date", ["from:2014-04-01 00:00,to:2014-04-02 00:00"]) ]
      )

      result = builder.payload

      assert_equal(
        result,
        {"range"=>{"field_with_date"=>{"from"=>"2014-04-01", "to"=>"2014-04-02"}}}
      )
    end

  end

  context "search with a filter with multiple options" do
    should "have correct filter" do
      builder = QueryComponents::Filter.new(
        filters: [ text_filter("organisations", ["hm-magic", "hmrc"]) ],
      )

      result = builder.payload

      assert_equal(
        result,
        {"terms" => {"organisations" => ["hm-magic", "hmrc"]}}
      )
    end
  end

  context "search with a filter and rejects" do
    should "have correct filter" do
      builder = QueryComponents::Filter.new(
        filters: [
          text_filter("organisations", ["hm-magic", "hmrc"]),
          reject_filter("mainstream_browse_pages", ["benefits"]),
        ],
      )

      result = builder.payload

      assert_equal(
        result,
        {bool: {
          must: {"terms" => {"organisations" => ["hm-magic", "hmrc"]}},
          must_not: {"terms" => {"mainstream_browse_pages" => ["benefits"]}},
        }}
      )
    end
  end

  context "search with multiple filters" do
    should "have correct filter" do
      builder = QueryComponents::Filter.new(
        filters: [
          text_filter("organisations", ["hm-magic", "hmrc"]),
          text_filter("section", ["levitation"]),
        ],
      )

      result = builder.payload

      assert_equal(
        result,
        {:and => [
          {"terms" => {"organisations" => ["hm-magic", "hmrc"]}},
          {"terms" => {"section" => ["levitation"]}},
        ].compact}
      )
    end
  end
end
