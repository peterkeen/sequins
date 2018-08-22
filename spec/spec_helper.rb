require "bundler/setup"
require "sequins"
require 'timecop'
require 'rspec/rails/matchers/active_job'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    ActiveJob::Base.queue_adapter = :test    
  end

  config.after do
    Timecop.return
  end
end
