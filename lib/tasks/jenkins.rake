begin
  require "ci/reporter/rake/minitest"
  require 'robottelo/reporter/rake/minitest'

  namespace :jenkins do
    task :unit => ['jenkins:setup:minitest', 'rake:test:units', 'rake:test:functionals', 'rake:test:graphql']
    task :integration => ['webpack:compile', 'jenkins:setup:minitest', 'rake:test:integration']
    task :functionals => ["jenkins:setup:minitest", 'rake:test:functionals']
    task :external => ['rake:test:external']
    task :units => ["jenkins:setup:minitest", 'rake:test:units']

    namespace :setup do
      task :pre_ci do
        ENV["CI_REPORTS"] = 'jenkins/reports/unit/'
        gem 'ci_reporter'
      end
      minitest_plugins = [:pre_ci, 'ci:setup:minitest']
      minitest_plugins << 'robottelo:setup:minitest' if ENV['GENERATE_ROBOTTELO_REPORT'] == 'true'
      task :minitest => minitest_plugins
    end

    task :rubocop do
      system("bundle exec rubocop \
        --require rubocop/formatter/checkstyle_formatter \
        --format RuboCop::Formatter::CheckstyleFormatter \
        --no-color --out rubocop.xml")
      exit($CHILD_STATUS.exitstatus)
    end
  end
rescue LoadError
  # ci/reporter/rake/rspec not present, skipping this definition
end
