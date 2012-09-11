begin
  require 'ci/reporter/rake/test_unit'
  namespace :jenkins do
    task :unit => ["jenkins:setup:test_unit", 'rake:test']

    namespace :setup do
      task :pre_ci do
        ENV["CI_REPORTS"] = 'jenkins/reports/unit/'
        gem 'ci_reporter'
      end
      task :test_unit => [:pre_ci, "ci:setup:testunit"]
    end
  end
rescue LoadError
  # ci/reporter/rake/rspec not present, skipping this definition
end

