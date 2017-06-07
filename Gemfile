source "https://rubygems.org"

gem "thin"
gem "foreman", "< 0.65.0"
gem "unicorn", "4.6.2"
gem "sinatra", "1.3.4"
gem "rake", "0.9.2", :require => false
gem "rack", "~> 1.6"
gem "rest-client", "1.8.0"
gem "logging", "1.8.1"
gem 'nokogiri', "~> 1.5"
gem 'whenever', require: false
gem "slop", "3.4.5"
gem "sidekiq", "2.13.0"
# pin to version that includes security vulnerability fix
gem "activesupport", "~> 3.2"
gem "redis-namespace", "1.3.1"
gem "plek", "1.5.0"
gem "gds-api-adapters", "~> 21.0"
gem "rack-logstasher", "0.0.3"
gem 'airbrake', '~> 4.0'
gem "unf", "0.1.3"

group :test do
  gem "shoulda-context"
  gem "simplecov", "~> 0.10.0"
  gem "simplecov-rcov"
  gem 'turn', require: false # Pretty printed test output
  gem "ci_reporter", "1.7.1"
  gem "minitest", "4.7.5"
  gem "rack-test"
  gem "mocha", :require => false
  gem "webmock", "~> 1.21.0", require: false
  gem "timecop", "0.7.3"
end

group :development do
  # (Intelligent) reloading server in development
  gem "mr-sparkle", "0.3.0"
end

gem "pry", group: [:development, :test]
