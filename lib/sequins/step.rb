module Sequins
  class Step
    attr_reader :target

    def initialize(target, sequence)
      @target = target
      @sequence = sequence
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
