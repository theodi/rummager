require 'test_helper'

class QueryBuilderTest < ShouldaUnitTestCase
  def setup
    Search::BestBetsChecker.any_instance.stubs best_bets: [], worst_bets: []
  end

  context "with a simple search query" do
    should "return a correct query object" do
      builder = builder_with_params(start: 11, count: 34, return_fields: ['a_field'])

      result = builder.payload
      assert_equal 11, result[:from]
      assert_equal 34, result[:size]
      assert result[:fields].include?('a_field')
      assert result.key?(:query)
    end
  end

  context "more like this" do
    should "call the payload for a more like this query" do
      builder = builder_with_params(similar_to: %{"/hello-world"})

      builder.expects(:more_like_this_query_hash).once

      # TODO: assert what the payload looks like
      builder.payload
    end
  end

  def builder_with_params(params)
    Search::QueryBuilder.new(
      search_params: Search::QueryParameters.new({ filters: [] }.merge(params)),
      content_index_names: SearchConfig.instance.content_index_names,
      metasearch_index: SearchConfig.instance.metasearch_index
    )
  end
end