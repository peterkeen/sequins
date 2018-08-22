module Sequins
  class DelayWorker < ActiveJob::Base
    def perform(sequence_class_name, target_class_name, target_id, next_step)
      sequence_class = sequence_class_name.constantize
      target = target_class_name.constantize.find(target_id)

      sequence_class.new.run_step_for_target(next_step.to_sym, target)
    end
  end
end
