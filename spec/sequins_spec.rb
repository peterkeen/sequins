RSpec.describe Sequins do
  Target = Struct.new(:last_run_step, :did_start, :did_end, :did_after, :sent_message, :id)

  include RSpec::Rails::Matchers

  class InvalidSequence < Sequins::Base
    sequence do
      step :whatever do
        #noop
      end
    end
  end

  class TestSequence < Sequins::Base
    sequence do
      before_sequence do
        target.did_start = step_name
      end

      after_sequence do
        target.did_end = step_name
      end

      before_each_step do
        target.last_run_step = step_name
      end

      after_each_step do
        target.did_after = true
      end

      step :first_step, initial: true do
        send_message target, :first_step_message

        delay 3 * 24 * 60 * 60, then: :second_step
      end

      step :second_step do
        end_sequence
      end

      step :basic_delay_step do
        delay 1.day, then: :delay_finish
      end

      step :only_weekdays_delay_step do
        delay 1.day, only: :weekdays, then: :delay_finish
      end

      step :specific_time_delay_step do
        delay 1.day, at: '11am', then: :delay_finish
      end

      step :step_with_args do |a, b|
        send_message target, "#{a} #{b}"
      end

      step :delay_finish do
        # noop
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

    it "should call the after hooks" do
      TestSequence.new.run_step_for_target(:first_step, subject)      
      expect(subject.did_after).to be_truthy
    end

    it "should raise an error for an invalid step" do
      expect {
        TestSequence.new.run_step_for_target(:invalid_step, subject)
      }.to raise_error(Sequins::UnknownStepError)
    end

    it "should pass args along to step block" do
      TestSequence.new.run_step_for_target(:step_with_args, subject, 'a', 'b')
      expect(subject.sent_message).to eq 'a b'      
    end

    it "should not error if args passed to step block that does not expect them" do
      TestSequence.new.run_step_for_target(:first_step, subject, 'a', 'b')
    end    
  end

  describe "before_sequence hook" do
    it "should run" do
      TestSequence.trigger(subject)
      expect(subject.did_start).to eq :_before_sequence
    end
  end

  describe "no initial step" do
    it "should error" do
      expect {
        InvalidSequence.trigger(subject)
      }.to raise_error(Sequins::NoInitialStepError)
    end
  end

  describe "after_sequence hook" do
    it "should run after end_sequence" do
      TestSequence.new.run_step_for_target(:second_step, subject)
      expect(subject.did_end).to eq :_after_sequence
    end
  end

  describe "trigger" do
    it "should run the initial step" do
      TestSequence.trigger(subject)
      expect(subject.last_run_step).to eq :first_step
    end

    it "should allow an override initial step" do
      TestSequence.trigger(subject, override_initial_step: :second_step)
      expect(subject.last_run_step).to eq :second_step
    end
  end

  describe "delay" do
    it 'should run the next step after the given delay' do
      Timecop.freeze

      expect {
        TestSequence.new.run_step_for_target(:basic_delay_step, subject)
      }.to have_enqueued_job(Sequins::DelayWorker).at(Time.now + 1.day)
    end

    it 'should account for weekdays' do
      Timecop.freeze('2018-07-28 10:00:00')

      expect {
        TestSequence.new.run_step_for_target(:only_weekdays_delay_step, subject)
      }.to have_enqueued_job(Sequins::DelayWorker).at(Time.now + 2.days)
    end

    it 'should account for an at param' do
      zone = ActiveSupport::TimeZone['America/Chicago']
      Timecop.freeze(zone.parse('2018-07-28 10:00:00'))

      expect {
        TestSequence.new.run_step_for_target(:specific_time_delay_step, subject)
      }.to have_enqueued_job(Sequins::DelayWorker).at(zone.parse('2018-07-29 11:00:00'))
    end
  end

end
