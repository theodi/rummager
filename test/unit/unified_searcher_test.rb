require "test_helper"
require "unified_searcher"

class UnifiedSearcherTest < ShouldaUnitTestCase
  context "#search" do
    should 'search with the results from the builder and return a presenter' do
      index = stub('index', :schema)
      searcher = UnifiedSearcher.new(index, stub)

      search_payload = stub('payload')
      UnifiedSearchBuilder.any_instance.expects(:payload).returns(search_payload)
      index.expects(:raw_search).with(search_payload).returns({})

      FacetExampleFetcher.any_instance.expects(:fetch).returns(stub('fetch'))
      UnifiedSearchPresenter.any_instance.expects(:present).returns(stub('presenter'))

      searcher.search({})
    end
  end
end
