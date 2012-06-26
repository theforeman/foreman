require File.expand_path('../config/application', __FILE__)
require 'rake'
include Rake::DSL

if Rails.env.test?
  require 'single_test'
  SingleTest.load_tasks
end

Foreman::Application.load_tasks
