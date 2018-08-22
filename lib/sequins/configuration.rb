module Sequins
  class Configuration
    attr_accessor :default_time_zone

    def initialize
      if Object.const_defined?('Rails') && !Rails.configuration.time_zone.nil?
        self.default_time_zone = Rails.configuration.time_zone
      else
        self.default_time_zone = 'America/Chicago'
      end
    end
  end
end
