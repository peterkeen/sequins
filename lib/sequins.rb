require 'docile'
require 'tod'
require 'tod/core_extensions'
require 'active_job'
require 'active_support'
require 'autoloaded'

module Sequins
  Autoloaded.module { }

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield configuration
  end

  def self.schedule_delay(delay_until, sequence_class, target, next_step)
    configuration.delay_scheduler.call(delay_until, sequence_class, target, next_step)
  end
end

require 'sequins/errors'
