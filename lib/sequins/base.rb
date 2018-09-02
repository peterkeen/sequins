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
  
    def self.trigger(target, *args)
      sequence.trigger(target, *args)
    end
  
    def trigger(target, *args)
      self.class.trigger(target, *args)
    end
  
    def run_step_for_target(step_name, target, *args)
      self.class.sequence.run_step_for_target(step_name, target, *args)
    end    
  end
end
