begin
  require "ci/reporter/rake/minitest"

  namespace :foreman do
    task :set_test_runner do
      ENV['TESTOPTS'] = "#{ENV['TESTOPTS']} #{Rails.root}/test/test_runner.rb"
    end
  end

  namespace :jenkins do
    desc "CI test task for the full test suite"
    task :unit => ["jenkins:setup:minitest", 'rake:test:units', 'rake:test:lib', 'rake:test:functionals']
    
    desc "CI test task for the integration test suite"
    task :integration => ["jenkins:setup:minitest", 'rake:test:integration']
    
    desc "CI test task for the lib test suite"
    task :lib => ["jenkins:setup:minitest", 'rake:test:lib']
    
    desc "CI test task for the functionals test suite"
    task :functionals => ["jenkins:setup:minitest", 'rake:test:functionals']
    
    desc "CI test task for the unit test suite"
    task :units => ["jenkins:setup:minitest", 'rake:test:units']

    namespace :setup do
      task :pre_ci do
        ENV["CI_REPORTS"] = 'jenkins/reports/unit/'
        gem 'ci_reporter'
      end
      task :minitest  => [:pre_ci, "ci:setup:minitest", "foreman:set_test_runner"]
    end

    task :rubocop do
      system("bundle exec rubocop \
        --require rubocop/formatter/checkstyle_formatter \
        --format RuboCop::Formatter::CheckstyleFormatter \
        --no-color --out rubocop.xml")
      exit($?.exitstatus)
    end
  end
rescue LoadError
  # ci/reporter/rake/rspec not present, skipping this definition
end

