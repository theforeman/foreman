if ENV['BUILD']
  load File.expand_path('../lib/tasks/pkg.rake', __FILE__)
else
  require File.expand_path('../config/application', __FILE__)
  require 'rake'
  require 'rake/testtask'
  include Rake::DSL

  require 'single_test/tasks' if defined? SingleTest

  Foreman::Application.load_tasks
end
