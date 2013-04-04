require File.expand_path('../config/application', __FILE__)
require 'rake'
include Rake::DSL
require 'jslint/tasks' unless Rails.env.production?

SingleTest.load_tasks if defined? SingleTest

Foreman::Application.load_tasks
