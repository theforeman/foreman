begin
  require "ci/reporter/rake/minitest"
  namespace :jenkins do
    task :unit => ["jenkins:setup:minitest", 'rake:test:units', 'rake:test:lib', 'rake:test:functionals']
    task :integration => ["jenkins:setup:minitest", 'rake:test:integration']
    task :lib => ["jenkins:setup:minitest", 'rake:test:lib']
    task :functionals => ["jenkins:setup:minitest", 'rake:test:functionals']
    task :units => ["jenkins:setup:minitest", 'rake:test:units']

    namespace :setup do
      task :pre_ci do
        ENV["CI_REPORTS"] = 'jenkins/reports/unit/'
        gem 'ci_reporter'
      end
      task :minitest  => [:pre_ci, "ci:setup:minitest"]
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

