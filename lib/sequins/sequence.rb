module Sequins
  class Sequence
    StepProxy = Struct.new(:options, :block)  

    attr_reader :klass
    
    def initialize(klass)
      @klass = klass
      @steps = {}
      @before_each_step_hooks = []
      @before_sequence_hooks = []
      @after_sequence_hooks = []
    end

    def add_step(name, options={}, &block)
      @steps[name] = StepProxy.new(options, block)
    end

    def add_before_each_step_hook(&block)
      @before_each_step_hooks << StepProxy.new({}, block)
    end

    def add_before_sequence_hook(&block)
      @before_sequence_hooks << StepProxy.new({}, block)
    end    

    def add_after_sequence_hook(&block)
      @after_sequence_hooks << StepProxy.new({}, block)      
    end

    def run_step_for_target(step_name, target)
      proxy = @steps[step_name]
      raise UnknownStepError.new(step_name) if proxy.nil?

      unless run_before_each_step_hooks_for_target(target)
        run_after_sequence_hooks_for_target(target)
        return false
      end

      step = Docile.dsl_eval(Step.new(target, self), &(proxy.block))
      if step.sequence_ended?
        run_after_sequence_hooks_for_target(target)
        return false
      end
    end

    def run_before_each_step_hooks_for_target(target)
      @before_each_step_hooks.each do |hook|
        step = Docile.dsl_eval(Step.new(target, self), &(hook.block))
        return false if step.sequence_ended?
      end
    end

    def run_before_sequence_hooks_for_target(target)
      @before_sequence_hooks.each do |hook|
        step = Docile.dsl_eval(Step.new(target, self), &(hook.block))
        return false if step.sequence_ended?
      end        
    end

    def run_after_sequence_hooks_for_target(target)
      @after_sequence_hooks.each do |hook|
        step = Docile.dsl_eval(Step.new(target, self), &(hook.block))
        return false if step.sequence_ended?
      end        
    end    

    def delay(duration, target, options)
      delay_until = Time.now + duration

      if options[:only] == :weekdays
        current_wday = delay_until.wday

        if current_wday == 0
          delay_until += 1.day
        elsif current_wday == 6
          delay_until += 2.days
        end
      end

      if !options[:at].nil?
        tod = Tod::TimeOfDay.parse(options[:at])
        delay_until = delay_until.to_date.at(tod)
      end

      next_step = options[:then]

      Sequins::DelayWorker.set(wait_until: delay_until).perform_later(@klass.to_s, target.class.to_s, target.id, next_step.to_s)
    end

    def trigger(target)
      unless run_before_sequence_hooks_for_target(target)
        run_after_sequence_hooks_for_target(target)
        return false
      end

      step_name, _ = @steps.detect { |_, s| s.options[:initial] }
      run_step_for_target(step_name, target)
    end

  end
end
