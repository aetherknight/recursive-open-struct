$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
