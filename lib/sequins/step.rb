module Sequins
  class Step
    attr_reader :target, :step_name

    def initialize(target, sequence, step_name)
      @target = target
      @sequence = sequence
      @step_name = step_name
    end

    def end_sequence
      @ended = true
    end

    def delay(duration, options)
      @sequence.delay(duration, target, options)
    end

    def sequence_ended?
      @ended
    end
  end
end
