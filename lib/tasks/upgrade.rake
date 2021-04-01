# TRANSLATORS: do not translate
desc <<-END_DESC
  This task runs predefined upgrade steps.

  Examples:
    rake upgrade:run
    rake upgrade:mark_as_ran TASK_NAME=some_rake_task,another_rake_task

END_DESC

namespace :upgrade do
  task :run => :environment do
    ENV['FOREMAN_UPGRADE'] = '1'

    raise "DB migration has not run" if ActiveRecord::Base.connection.migration_context.needs_migration?
    raise "DB seed has not run" if Setting['db_pending_seed']

    total = UpgradeTask.needing_run.count
    UpgradeTask.needing_run.each_with_index do |task, index|
      count = "#{index + 1}/#{total}"

      message = "Upgrade Step #{count}: #{task.name}. "
      message += "This may take a long while." if task.long_running?

      puts '============================================='
      puts message
      task.mark_as_ran! if run_task(task)
    end
  end

  def run_task(task)
    Rake::Task[task.task_name].execute
  rescue => e
    puts "Failed upgrade task: #{task.name}, see logs for more information."

    if task.skip_failure?
      Foreman::Logging.exception("Failed upgrade task: #{task.name}", e)
      false
    end

    true
  end
end
