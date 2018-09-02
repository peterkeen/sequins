module Sequins
  class Sequence
    StepProxy = Struct.new(:options, :block)  

    attr_reader :klass
    
    def initialize(klass)
      @klass = klass
      @steps = {}
      @hooks = {}
    end

    def add_step(name, options={}, &block)
      @steps[name] = StepProxy.new(options, block)
    end

    def add_hook(stage, &block)
      @hooks[stage] ||= []
      @hooks[stage] << StepProxy.new({}, block)
    end

    def run_step_for_target(step_name, target, *args)
      proxy = @steps[step_name]
      raise UnknownStepError.new(step_name) if proxy.nil?

      unless run_hooks_for_target(:before_each_step, target, step_name)
        run_hooks_for_target(:after_sequence, target, :_after_sequence)
        return false
      end

      step = Docile.dsl_eval(Step.new(target, self, step_name), args, &(proxy.block))

      ended_after_each = !run_hooks_for_target(:after_each_step, target, step_name)      

      if step.sequence_ended? || ended_after_each
        run_hooks_for_target(:after_sequence, target, :_after_sequence)
        return false
      end
    end

    def run_hooks_for_target(stage, target, step_name)
      return if @hooks[stage].nil? || @hooks[stage].empty?

      @hooks[stage].each do |hook|
        step = Docile.dsl_eval(Step.new(target, self, step_name), &(hook.block))
        return false if step.sequence_ended?
      end        
    end    

    def delay(duration, target, options)
      if target.respond_to?(:local_time_zone)
        zone = ActiveSupport::TimeZone[target.local_time_zone]
      else
        zone = ActiveSupport::TimeZone[Sequins.configuration.default_time_zone]
      end

      delay_until = zone.now + duration

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
        delay_until = delay_until.to_date.at(tod, zone)
      end

      next_step = options[:then]

      Sequins::DelayWorker.set(wait_until: delay_until).perform_later(@klass.to_s, target.class.to_s, target.id, next_step.to_s)
    end

    def trigger(target, *args)
      step_name, _ = @steps.detect { |_, s| s.options[:initial] }
      raise NoInitialStepError.new unless step_name.present?

      unless run_hooks_for_target(:before_sequence, target, :_before_sequence)
        run_hooks_for_target(:after_sequence, target, :_after_sequence)
        return false
      end

      run_step_for_target(step_name, target, *args)
    end

  end
end
