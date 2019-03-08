module Sequins
  class Configuration
    attr_accessor :default_time_zone, :delay_scheduler

    def initialize
      if Object.const_defined?('Rails') && !Rails.configuration.time_zone.nil?
        self.default_time_zone = Rails.configuration.time_zone
      else
        self.default_time_zone = 'America/Chicago'
      end

      self.delay_scheduler = lambda do |delay_until, sequence_class, target, next_step|
        Sequins::DelayWorker
          .set(wait_until: delay_until)
          .perform_later(sequence_class.to_s, target.class.to_s, target.id, next_step.to_s)
      end
    end
  end
end
