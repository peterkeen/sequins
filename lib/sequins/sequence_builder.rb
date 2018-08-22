module Sequins
  class SequenceBuilder
    def initialize(klass)
      @seq = Sequence.new(klass)
      @klass = klass
    end

    def step(name, options={}, &block)
      @seq.add_step(name, options, &block)
      self
    end

    def before_each_step(&block)
      @seq.add_before_each_step_hook(&block)
    end

    def before_sequence(&block)
      @seq.add_before_sequence_hook(&block)
    end

    def after_sequence(&block)
      @seq.add_after_sequence_hook(&block)
    end

    def build
      @seq
    end
  end
end
