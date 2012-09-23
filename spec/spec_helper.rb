require "rspec"
require "rdo"

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each do |file|
  require file
end

RSpec.configure do |config|
  config.mock_with :rspec
end
