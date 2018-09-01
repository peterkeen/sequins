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
      @seq.add_hook(:before_each_step, &block)
    end

    def after_each_step(&block)
      @seq.add_hook(:after_each_step, &block)
    end

    def before_sequence(&block)
      @seq.add_hook(:before_sequence, &block)
    end

    def after_sequence(&block)
      @seq.add_hook(:after_sequence, &block)
    end

    def build
      @seq
    end
  end
end
