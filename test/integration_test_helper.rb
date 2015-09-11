require "test_helper"
require "app"
require "elasticsearch/search_server"
require "sidekiq/testing/inline"  # Make all queued jobs run immediately
require "support/elasticsearch_integration_helpers"
require "support/integration_fixtures"

module ElasticsearchIntegration

  def stub_elasticsearch_settings(index_names = ["rummager_test"], default = nil)
    index_names.each do |n| check_index_name(n) end
    check_index_name(default) unless default.nil?

    @default_index_name = default || index_names.first

    app.settings.search_config.stubs(:elasticsearch).returns({
      "base_uri" => "http://localhost:9200",
      "index_names" => index_names
    })
    app.settings.stubs(:default_index_name).returns(@default_index_name)
    app.settings.stubs(:enable_queue).returns(false)
  end

  def enable_test_index_connections
    WebMock.disable_net_connect!(allow: %r{http://localhost:9200/(_search/scroll|_aliases|[a-z]+_test.*)})
  end

  def try_remove_test_index(index_name = @default_index_name)
    check_index_name(index_name)
    RestClient.delete "http://localhost:9200/#{CGI.escape(index_name)}"
  rescue RestClient::ResourceNotFound
    # Index doesn't exist: that's fine
  end

  def clean_index_group(group_name = @default_index_name)
    check_index_name(group_name)
    index_group = search_server.index_group(group_name)
    # Delete any indices left over from switching
    index_group.clean
    # Clean up the test index too, to avoid the possibility of inter-dependent
    # tests. It also keeps the index view cleaner.
    if index_group.current.exists?
      index_group.send(:delete, index_group.current.real_name)
    end
  end

end

class IntegrationTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include IntegrationFixtures
  include ElasticsearchIntegrationHelpers

  def app
    Rummager
  end

private

  def deep_copy(hash)
    Marshal.load(Marshal.dump(hash))
  end
end
