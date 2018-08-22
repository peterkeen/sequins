module Sequins
  class Base
    def self.sequence(&block)
      if block_given?
        @_sequence = Docile.dsl_eval(SequenceBuilder.new(self), &block).build
        after_sequence_build(@_sequence) if respond_to?(:after_sequence_build)
      else
        @_sequence
      end
    end
  
    def self.sequence_name
      self.to_s.underscore.gsub(/_sequence$/, '')
    end
  
    def self.trigger(target)
      sequence.trigger(target)
    end
  
    def trigger(target)
      self.class.trigger(target)
    end
  
    def run_step_for_target(step_name, target)
      self.class.sequence.run_step_for_target(step_name, target)
    end    
  end
end
