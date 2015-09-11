require_relative "../../test_helper"
require "health_check/logging_config"
require "health_check/search_check"
Logging.logger.root.appenders = nil

module HealthCheck
  class SearchCheckTest < ShouldaUnitTestCase
    context "result" do
      context "'should' checks" do
        should "return a Result" do
          check = SearchCheck.new("carmen", "should", "/a", 1, 200)
          search_results = ["https://www.gov.uk/a"]

          result = check.result(search_results)

          assert_equal true, result.success
          assert_equal 200, result.score
          assert_equal 200, result.possible_score
        end

        context "desired result is outside of the desired ranking" do
          should "return a failure Result" do
            check = SearchCheck.new("carmen", "should", "/a", 1, 200)
            search_results = ["https://www.gov.uk/b", "https://www.gov.uk/a"]

            result = check.result(search_results)

            assert_equal false, result.success
            assert_equal 0, result.score
            assert_equal 200, result.possible_score
          end
        end

        context "desired result isn't in the results" do
          should "return a failure Result" do
            check = SearchCheck.new("carmen", "should", "/a", 1, 200)
            search_results = ["https://www.gov.uk/b", "https://www.gov.uk/a"]

            result = check.result(search_results)

            assert_equal false, result.success
            assert_equal 0, result.score
            assert_equal 200, result.possible_score
          end
        end
      end
    end

    context "'should not' checks" do
      context "an undesirable result is in the top N" do
        should "fail" do
          check = SearchCheck.new("carmen", "should not", "/a", 1, 200)
          search_results = ["https://www.gov.uk/a", "https://www.gov.uk/b"]

          logger = mock("logger")
          logger.expects(:fail)
          check.stubs(:logger).returns(logger)

          result = check.result(search_results)

          assert_equal false, result.success
        end
      end

      context "an undesirable result is after the top N" do
        should "pass" do
          check = SearchCheck.new("carmen", "should not", "/a", 1, 200)
          search_results = ["https://www.gov.uk/b", "https://www.gov.uk/a"]

          logger = mock("logger")
          logger.expects(:pass)
          check.stubs(:logger).returns(logger)

          result = check.result(search_results)

          assert_equal true, result.success
        end
      end

      context "an undesirable result doesn't appear" do
        should "pass" do
          check = SearchCheck.new("carmen", "should not", "/x", 1, 200)
          search_results = ["https://www.gov.uk/a", "https://www.gov.uk/b"]

          logger = mock("logger")
          logger.expects(:pass)
          check.stubs(:logger).returns(logger)

          result = check.result(search_results)

          assert_equal true, result.success
        end
      end
    end
  end
end
