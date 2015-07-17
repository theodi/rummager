ENV['RACK_ENV'] = 'test'

# Simplecov should be required before any other code is loaded statement to prevent
# false negatives.
if ENV["USE_SIMPLECOV"]
  require "simplecov"
  require "simplecov-rcov"
  SimpleCov.start do
    add_filter '/test/'
  end

  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
end

$LOAD_PATH << File.expand_path('../../', __FILE__)
$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'app'

require "bundler/setup"
require "minitest/autorun"
require 'turn/autorun'
require "rack/test"
require "mocha/setup"
require "fixtures/default_mappings"
require "pp"
require "shoulda-context"
require "logging"
require "timecop"

require "webmock/minitest"
WebMock.disable_net_connect!

require "sample_config"

module TestHelpers
  include SampleConfig

  def teardown
    Timecop.return
  end

  def load_yaml_fixture(filename)
    YAML.load_file(File.expand_path("fixtures/#{filename}", File.dirname(__FILE__)))
  end

  # This can be used to partially match a hash in the context of an assert_equal
  # e.g. The following would pass
  #
  # assert_equal hash_including(one: 1), {one: 1, two: 2}
  #
  def hash_including(subset)
    HashIncludingMatcher.new(subset)
  end

  class HashIncludingMatcher
    def initialize(subset)
      @subset = subset
    end

    def ==(other)
      @subset.all? { |k,v|
        other.has_key?(k) && v == other[k]
      }
    end

    def inspect
      @subset.inspect
    end
  end

  def stub_elasticsearch_request(hash)
    hash.each do |url, response|
      stub_request(:get, "http://localhost:9200#{url}").to_return(body: JSON.dump(response))
    end
  end

  def search_query_params(options={})
    {
      start: 0,
      count: 20,
      query: "cheese",
      order: nil,
      filters: {},
      fields: nil,
      facets: nil,
      debug: {},
    }.merge(options)
  end
end

class MiniTest::Unit::TestCase
  include TestHelpers
end

class ShouldaUnitTestCase < MiniTest::Unit::TestCase
  include Shoulda::Context::Assertions
  include Shoulda::Context::InstanceMethods
  extend Shoulda::Context::ClassMethods
end
