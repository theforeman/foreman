namespace :dynflow do
  desc <<~END_DESC
    In development mode, the Dynflow executor is part of the web server process. However, in production, it's more suitable to have the web server process separated from the async executor. Therefore, Dynflow is set to use external process in production mode by default (can be changed with Foreman.dynflow.config.remote = false). This task can be used to start the executor manually in development mode.

    The executor process needs to be executed before the web server. You can run it by:

      foreman-rake foreman_tasks:dynflow:executor

  END_DESC
  task :executor => :environment do
    Dynflow::Rails::Daemon.new.run
  end

  def dynflow_persistence
    @persistence ||= begin
                       config = Dynflow::Rails::Configuration.new
                       config.db_pool_size = 1 # To prevent automatic detection
                       config.send(:initialize_persistence, nil, :migrate => false, :logger => Foreman::Logging.logger('sql'))
                     end
  end

  task :migrate => :environment do
    dynflow_persistence.migrate_db
  end

  task :abort_if_pending_migrations => :environment do
    dynflow_persistence.abort_if_pending_migrations!
  end

  desc <<~END_DESC
    Sets up the environment to act as a Dynflow client. By acting as a client, it still send tasks to be processed, but it cannot execute tasks.
  END_DESC
  task :client => :environment do
    dynflow = ::Rails.application.dynflow
    dynflow.config.remote = true
    dynflow.initialize!
  end
end

%w(migrate abort_if_pending_migrations).each do |task|
  Rake::Task["db:#{task}"].enhance do
    Rake::Task["dynflow:#{task}"].invoke
  end
end
