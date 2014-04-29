require "integration_test_helper"
require "rest-client"
require_relative "multi_index_test"

class UnifiedSearchTest < MultiIndexTest

  def test_returns_success
    get "/unified_search?q=important"
    assert last_response.ok?
  end

  def test_returns_docs_from_all_indexes
    get "/unified_search?q=important"
    links = parsed_response["results"].map do |result|
      result["link"]
    end
    assert links.include? "/detailed-1"
    assert links.include? "/government-1"
    assert links.include? "/mainstream-1"
  end

  def test_sort_by_date_ascending
    get "/unified_search?q=important&order=public_timestamp"
    links = parsed_response["results"].map do |result|
      result["link"]
    end
    assert_equal ["/government-1", "/government-2"], links
  end

  def test_sort_by_date_descending
    get "/unified_search?q=important&order=-public_timestamp"
    links = parsed_response["results"].map do |result|
      result["link"]
    end
    assert_equal ["/government-2", "/government-1"], links
  end

  def test_filter_by_section
    get "/unified_search?filter_section=1"
    assert last_response.ok?
    links = parsed_response["results"].map do |result|
      result["link"]
    end
    links.sort!
    assert_equal links, ["/detailed-1", "/government-1", "/mainstream-1"], links
  end

  def test_only_contains_fields_which_are_present
    get "/unified_search?q=important&order=public_timestamp"
    results = parsed_response["results"]
    refute_includes results[0].keys, "topic"
    assert_equal ["2"], results[1]["section"]
  end

  def test_facet_counting
    get "/unified_search?q=important&facet_section=2"
    assert_equal 6, parsed_response["total"]
    facets = parsed_response["facets"]
    assert_equal({
      "section" => {
        "options" => [
          {"value"=>"2", "documents"=>3},
          {"value"=>"1", "documents"=>3},
        ],
        "documents_with_no_value" => 0,
        "total_options" => 2,
        "missing_options" => 0,
      }
    }, facets)
  end

  def test_facet_counting_missing_options
    get "/unified_search?q=important&facet_section=1"
    assert_equal 6, parsed_response["total"]
    facets = parsed_response["facets"]
    assert_equal({
      "section" => {
        "options" => [
          {"value"=>"2", "documents"=>3},
        ],
        "documents_with_no_value" => 0,
        "total_options" => 2,
        "missing_options" => 1,
      }
    }, facets)
  end

  def test_validates_integer_params
    get "/unified_search?start=a"
    assert_equal last_response.status, 400
    assert_equal parsed_response, {"error" => "Invalid value \"a\" for parameter \"start\" (expected positive integer)"}
  end

  def test_allows_integer_params_leading_zeros
    get "/unified_search?start=09"
    assert last_response.ok?
  end

  def test_validates_unknown_params
    get "/unified_search?foo&bar=1"
    assert_equal last_response.status, 400
    assert_equal parsed_response, {"error" => "Unexpected parameters: foo, bar"}
  end
end
