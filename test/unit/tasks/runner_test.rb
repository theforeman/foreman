require 'test_helper'
require 'rake'
require 'rails/command'

class RunnerTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require 'tasks/runner'
    Rake::Task.define_task(:"dynflow:client")
    Rake::Task[:runner].reenable
    @argv = ARGV.dup
    @current_user = User.current
  end

  teardown do
    ARGV.replace(@argv)
    User.current = @current_user
  end

  test 'passes arguments to Rails runner as the console admin' do
    ARGV.replace(['runner', '--', 'puts Host.count'])
    console_admin = FactoryBot.create(:user)
    User.stubs(:anonymous_console_admin).returns(console_admin)
    ::Rails::Command.expects(:invoke).with('runner', ['puts Host.count'])

    Rake::Task[:runner].invoke

    assert_equal console_admin, User.current
  end
end
