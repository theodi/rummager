require "test_helper"
require "search_parameter_parser"

class SearchParameterParserTest < ShouldaUnitTestCase

  def expected_params(params)
    {
      start: 0,
      count: 10,
      query: nil,
      order: nil,
      return_fields: SearchParameterParser::ALLOWED_RETURN_FIELDS,
      filters: {},
      facets: {},
      index: "dapaas,odi"
    }.merge(params)
  end

  should "return valid params given nothing" do
    p = SearchParameterParser.new({})

    assert_equal("", p.error)
    assert p.valid?
    assert_equal(expected_params({}), p.parsed_params)
  end

  should "complain about an unknown parameter" do
    p = SearchParameterParser.new({"p" => "extra"})

    assert_equal("Unexpected parameters: p", p.error)
    assert !p.valid?
    assert_equal(expected_params({}), p.parsed_params)
  end

  should "complain about multiple unknown parameters" do
    p = SearchParameterParser.new({"p" => "extra", "boo" => "goose"})

    assert_equal("Unexpected parameters: p, boo", p.error)
    assert !p.valid?
    assert_equal(expected_params({}), p.parsed_params)
  end

  should "understand the start parameter" do
    p = SearchParameterParser.new({"start" => "5"})

    assert_equal("", p.error)
    assert p.valid?
    assert_equal(expected_params(start: 5), p.parsed_params)
  end

  should "complain about a non-integer start parameter" do
    p = SearchParameterParser.new({"start" => "5.5"})

    assert_equal("Invalid value \"5.5\" for parameter \"start\" (expected positive integer)", p.error)
    assert !p.valid?
    assert_equal(expected_params({}), p.parsed_params)
  end

  should "complain about a negative start parameter" do
    p = SearchParameterParser.new({"start" => "-1"})

    assert_equal("Invalid negative value \"-1\" for parameter \"start\" (expected positive integer)", p.error)
    assert !p.valid?
    assert_equal(expected_params({}), p.parsed_params)
  end

  should "complain about a non-decimal start parameter" do
    p = SearchParameterParser.new({"start" => "x"})

    assert_equal("Invalid value \"x\" for parameter \"start\" (expected positive integer)", p.error)
    assert !p.valid?
    assert_equal(expected_params({}), p.parsed_params)
  end

  should "understand the count parameter" do
    p = SearchParameterParser.new({"count" => "5"})

    assert_equal("", p.error)
    assert p.valid?
    assert_equal(expected_params(count: 5), p.parsed_params)
  end

  should "complain about a non-integer count parameter" do
    p = SearchParameterParser.new({"count" => "5.5"})

    assert_equal("Invalid value \"5.5\" for parameter \"count\" (expected positive integer)", p.error)
    assert !p.valid?
    assert_equal(expected_params({}), p.parsed_params)
  end

  should "complain about a negative count parameter" do
    p = SearchParameterParser.new({"count" => "-1"})

    assert_equal("Invalid negative value \"-1\" for parameter \"count\" (expected positive integer)", p.error)
    assert !p.valid?
    assert_equal(expected_params({}), p.parsed_params)
  end

  should "complain about a non-decimal count parameter" do
    p = SearchParameterParser.new({"count" => "x"})

    assert_equal("Invalid value \"x\" for parameter \"count\" (expected positive integer)", p.error)
    assert !p.valid?
    assert_equal(expected_params({}), p.parsed_params)
  end

  should "understand the q parameter" do
    p = SearchParameterParser.new({"q" => "search-term"})

    assert_equal("", p.error)
    assert p.valid?
    assert_equal(expected_params(query: "search-term"), p.parsed_params)
  end

  should "complain about disallowed filter fields" do
    p = SearchParameterParser.new({"filter_spells" => "levitation"})

    assert_equal("\"spells\" is not a valid filter field", p.error)
    assert !p.valid?
  end

  should "understand an ascending sort" do
    p = SearchParameterParser.new({"order" => "public_timestamp"})

    assert_equal("", p.error)
    assert p.valid?
    assert_equal(expected_params({order: ["public_timestamp", "asc"]}), p.parsed_params)
  end

  should "understand a descending sort" do
    p = SearchParameterParser.new({"order" => "-public_timestamp"})

    assert_equal("", p.error)
    assert p.valid?
    assert_equal(expected_params({order: ["public_timestamp", "desc"]}), p.parsed_params)
  end

  should "complain about disallowed sort fields" do
    p = SearchParameterParser.new({"order" => "spells"})

    assert_equal("\"spells\" is not a valid sort field", p.error)
    assert !p.valid?
    assert_equal(expected_params({}), p.parsed_params)
  end

  should "complain about disallowed descending sort fields" do
    p = SearchParameterParser.new({"order" => "-spells"})

    assert_equal("\"spells\" is not a valid sort field", p.error)
    assert !p.valid?
    assert_equal(expected_params({}), p.parsed_params)
  end

  should "understand a facet field" do
    p = SearchParameterParser.new({"facet_format" => "10"})

    assert_equal("", p.error)
    assert p.valid?
    assert_equal(expected_params({facets: {"format" => 10}}), p.parsed_params)
  end

  should "understand multiple facet fields" do
    p = SearchParameterParser.new({
      "facet_format" => "10",
      "facet_section" => "5",
    })

    assert_equal("", p.error)
    assert p.valid?
    assert_equal(expected_params({facets: {"format" => 10, "section" => 5}}), p.parsed_params)
  end

  should "complain about disallowed facet fields" do
    p = SearchParameterParser.new({"facet_spells" => "10"})

    assert_equal("\"spells\" is not a valid facet field", p.error)
    assert !p.valid?
  end

  should "complain about invalid values for facet parameter" do
    p = SearchParameterParser.new({"facet_spells" => "levitation"})

    assert_equal("\"spells\" is not a valid facet field", p.error)
    assert !p.valid?
    assert_equal(expected_params({}), p.parsed_params)
  end

  should "understand the fields parameter" do
    p = SearchParameterParser.new({"fields" => ["title", "description"]})

    assert_equal("", p.error)
    assert p.valid?
    assert_equal(expected_params({return_fields: ["title", "description"]}), p.parsed_params)
  end

  should "complain about invalid fields parameters" do
    p = SearchParameterParser.new({"fields" => ["title", "waffle"]})

    assert_equal("Some requested fields are not valid return fields: [\"waffle\"]", p.error)
    assert !p.valid?
    assert_equal(expected_params({return_fields: ["title"]}), p.parsed_params)
  end

  should "return a single index" do
    p = SearchParameterParser.new({"index" => "odi"})

    assert_equal("", p.error)
    assert p.valid?
    assert_equal(expected_params({index: "odi"}), p.parsed_params)
  end

  should "complain about invalid indexes" do
    p = SearchParameterParser.new({"index" => "foobar"})

    assert_equal("foobar is not a valid index", p.error)
    assert !p.valid?
  end

end
