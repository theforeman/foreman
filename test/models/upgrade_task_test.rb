require 'test_helper'

class UpgradeTaskTest < ActiveSupport::TestCase
  test "needing run should return results" do
    task1 = UpgradeTask.create!(:name => 'task1', :subject => 'foreman')
    task2 = UpgradeTask.create!(:name => 'task2', :always_run => true, :last_run_time => Time.now, :subject => 'foreman')
    task3 = UpgradeTask.create!(:name => 'task3', :last_run_time => Time.now, :subject => 'foreman')

    assert_includes UpgradeTask.needing_run, task1
    assert_includes UpgradeTask.needing_run, task2
    refute_includes UpgradeTask.needing_run, task3
  end

  test "mark as ran causes task to not need run" do
    task1 = UpgradeTask.create!(:name => 'task1', :subject => 'foreman')
    assert_includes UpgradeTask.needing_run, task1

    task1.mark_as_ran!
    refute_includes UpgradeTask.needing_run, task1
  end

  test "defining tasks should update tasks" do
    UpgradeTask.define_tasks(:test_tasks) do
      [
        {:name => 'testTask1', :always_run => true},
      ]
    end

    assert UpgradeTask.find_by(:name => :testTask1).always_run?

    UpgradeTask.define_tasks(:test_tasks) do
      [
        {:name => 'testTask1', :always_run => false},
      ]
    end

    refute UpgradeTask.find_by(:name => :testTask1).always_run?
  end

  test "defining tasks should delete old tasks" do
    UpgradeTask.define_tasks(:test_tasks) do
      [
        {:name => 'testTask1'},
        {:name => 'testTask2'},
      ]
    end

    assert UpgradeTask.find_by(:name => 'testTask2')

    UpgradeTask.define_tasks(:test_tasks) do
      [
        {:name => 'testTask1'},
      ]
    end

    assert UpgradeTask.find_by(:name => 'testTask1')
    refute UpgradeTask.find_by(:name => 'testTask2')
  end

  test "task name should be pulled from name" do
    task1 = UpgradeTask.create!(:name => 'task1', :subject => 'foreman')

    assert_equal task1.name, task1.task_name
  end
end
