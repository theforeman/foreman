require 'test_helper'
require 'ostruct'

class ApplicationJobTest < ActiveSupport::TestCase
  describe '.spawn_if_missing' do
    let(:job_class) { ApplicationJob }

    # Using real world led to various issues, let's stub it out
    let(:world) do
      persistence = mock()
      persistence.stubs(:find_execution_plans).returns([])
      persistence.stubs(:load_delayed_plan)
      OpenStruct.new(:persistence => persistence)
    end

    def stub_delayed_plans_with_serialized_args(*args)
      execution_plans = args.each_with_index.map { |_, index| OpenStruct.new(:id => index) }
      world.persistence.expects(:find_execution_plans)
                       .with(:filters => { :state => %w(planning scheduled) }).returns(execution_plans)
      world.persistence.expects(:find_execution_plans).with(:filters => {:state => %w(planned running), :label => job_class.to_s}).returns([])
      args.each_with_index do |arg, index|
        delayed_plan = OpenStruct.new(:to_hash => { :serialized_args => arg })
        world.persistence.expects(:load_delayed_plan).with(index).returns(delayed_plan)
      end
    end

    describe 'when in rake' do
      before { Foreman.expects(:in_rake?).returns(true) }

      it 'runs in dynflow:executor rake task' do
        Foreman.expects(:in_rake?).with('dynflow:executor').returns(true)
        Rails.env.expects(:test?).returns(false)
        job_class.expects(:perform_later)

        job_class.spawn_if_missing world
      end

      it 'does not run in other rake tasks' do
        Foreman.expects(:in_rake?).with('dynflow:executor').returns(false)
        Rails.env.expects(:test?).never
        job_class.expects(:perform_later).never

        job_class.spawn_if_missing world
      end
    end

    describe 'when not in rake' do
      before { Foreman.expects(:in_rake?).returns(false) }

      it 'does not run in test environment' do
        Rails.env.expects(:test?).returns(true)
        job_class.expects(:perform_later).never

        job_class.spawn_if_missing world
      end

      describe 'when not in test environment' do
        before { Rails.env.expects(:test?).returns(false) }

        it 'runs' do
          job_class.expects(:perform_later)

          job_class.spawn_if_missing world
        end

        it 'does not trigger the job if it already exists' do
          stub_delayed_plans_with_serialized_args [{ 'job_class' => job_class.to_s }]
          job_class.expects(:perform_later).never

          job_class.spawn_if_missing world
        end

        it 'ignores other active jobs' do
          stub_delayed_plans_with_serialized_args [{ 'job_class' => 'NotTheClassWeAreLookingFor' }]
          job_class.expects(:perform_later)

          job_class.spawn_if_missing world
        end

        it 'does not crash when delayed jobs have unexpected arguments' do
          stub_delayed_plans_with_serialized_args [1]
          job_class.expects(:perform_later)

          job_class.spawn_if_missing world
        end

        it 'does not crash when delayed jobs have unexpected shape of arguments' do
          stub_delayed_plans_with_serialized_args [{'something' => 'not important' }]
          job_class.expects(:perform_later)

          job_class.spawn_if_missing world
        end

        it 'takes running plans into consideration' do
          world.persistence.expects(:find_execution_plans)
                           .with(:filters => { :state => %w(planning scheduled) }).returns([])
          world.persistence.expects(:find_execution_plans).with(:filters => {:state => %w(planned running), :label => job_class.to_s}).returns([1])
          job_class.expects(:perform_later).never

          job_class.spawn_if_missing world
        end
      end
    end
  end
end
