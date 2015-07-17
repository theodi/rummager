require "uri"
require "health_check/check_file_parser"
require "health_check/calculator"

module HealthCheck
  class SearchChecker
    attr_reader :search_client

    def initialize(options = {})
      @test_data_file = options[:test_data]
      @search_client = options[:search_client]
    end

    def run!
      Logging.logger[self].info("Connecting to #{@search_client.to_s}")

      checks.each do |check|
        search_results = search_client.search(check.search_term)[:results]
        result = check.result(search_results)
        calculator.add(result)
      end

      calculator
    end

    private
      def checks
        CheckFileParser.new(@test_data_file).checks.sort { |a,b| b.weight <=> a.weight }
      end

      def calculator
        @_calculator ||= Calculator.new
      end
  end
end
