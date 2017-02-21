namespace :dynflow do
  desc <<-END_DESC
In development mode, the Dynflow executor is part of the web server process. However, in production, it's more suitable to have the web server process separated from the async executor. Therefore, Dynflow is set to use external process in production mode by default (can be changed with Foreman.dynflow.config.remote = false). This task can be used to start the executor manually in development mode.

The executor process needs to be executed before the web server. You can run it by:

  foreman-rake foreman_tasks:dynflow:executor

END_DESC
  task :executor => :environment do
    Dynflow::Rails::Daemon.new.run
  end
end
