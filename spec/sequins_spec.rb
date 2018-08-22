RSpec.describe Sequins do

  Target = Struct.new(:last_run_step, :did_start, :did_end, :sent_message, :id)

  class TestSequence < Sequins::Base
    sequence do
      before_sequence do
        target.did_start = true
      end

      after_sequence do
        target.did_end = true
      end

      step :first_step, initial: true do
        target.last_run_step = :first_step

        send_message target, :first_step_message

        delay 3 * 24 * 60 * 60, then: :second_step
      end

      step :second_step do
        target.last_run_step = :second_step
        end_sequence
      end
    end

    def self.send_message(target, message)
      target.sent_message = message
    end
  end

  it "has a version number" do
    expect(Sequins::VERSION).not_to be nil
  end

  subject { Target.new }

  describe "run_step_for_target" do
    it "should run the step" do
      TestSequence.new.run_step_for_target(:first_step, subject)
      expect(subject.last_run_step).to eq :first_step
    end

    it "should be able to call methods on the sequence" do
      TestSequence.new.run_step_for_target(:first_step, subject)      
      expect(subject.sent_message).to eq :first_step_message
    end
  end

  describe "before_sequence hook" do
    it "should run" do
      TestSequence.trigger(subject)
      expect(subject.did_start).to be_truthy
    end
  end

  describe "after_sequence hook" do
    it "should run after end_sequence" do
      TestSequence.new.run_step_for_target(:second_step, subject)
      expect(subject.did_end).to be_truthy
    end
  end

end
