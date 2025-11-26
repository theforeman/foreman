require 'test_helper'
require 'foreman/cron'
require 'logger'

class Foreman::CronTest < ActiveSupport::TestCase
  setup do
    Foreman::Cron.instance_variable_set(:@tasks, nil)
    Foreman::Cron.instance_variable_set(:@logger, Logger.new(nil))
  end

  test 'register adds task for valid cadence' do
    Foreman::Cron.register(:daily, 'test:task')

    tasks = Foreman::Cron.send(:tasks_for, :daily)
    assert_includes tasks, 'test:task'
  end

  test 'register does not add duplicate tasks' do
    Foreman::Cron.register(:daily, 'test:task')
    Foreman::Cron.register(:daily, 'test:task')

    tasks = Foreman::Cron.send(:tasks_for, :daily)
    assert_equal 1, tasks.count('test:task')
  end

  test 'register ignores invalid cadence' do
    Foreman::Cron.register(:invalid, 'test:task')

    tasks = Foreman::Cron.send(:tasks_for, :invalid)
    assert_empty(tasks)
  end

  test 'run returns false when all tasks succeed' do
    Foreman::Cron.instance_variable_set(:@tasks, { daily: ['test:task'] })

    task = mock('rake_task')
    task.expects(:reenable).once
    task.expects(:invoke).once
    Rake::Task.stubs(:[]).with('test:task').returns(task)

    result = Foreman::Cron.run(:daily)

    assert_equal false, result
  end

  test 'run returns true when a task fails but continues executing others' do
    Foreman::Cron.instance_variable_set(:@tasks, { daily: %w[first second] })

    failing = mock('failing_task')
    failing.expects(:reenable).once
    failing.expects(:invoke).raises(StandardError.new('boom'))

    succeeding = mock('succeeding_task')
    succeeding.expects(:reenable).once
    succeeding.expects(:invoke).once

    Rake::Task.stubs(:[]).with('first').returns(failing)
    Rake::Task.stubs(:[]).with('second').returns(succeeding)

    result = Foreman::Cron.run(:daily)

    assert_equal true, result
  end

  test 'run returns false when no tasks are configured' do
    Foreman::Cron.instance_variable_set(:@tasks, { hourly: [] })

    result = Foreman::Cron.run(:hourly)

    assert_equal false, result
  end
end
