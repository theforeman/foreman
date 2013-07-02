begin
  require "ci/reporter/rake/minitest"
  namespace :jenkins do
    task :unit => ["jenkins:setup:minitest", 'rake:test']

    namespace :setup do
      task :pre_ci do
        ENV["CI_REPORTS"] = 'jenkins/reports/unit/'
        gem 'ci_reporter'
      end
      task :minitest  => [:pre_ci, "ci:setup:minitest"]
    end
  end
rescue LoadError
  # ci/reporter/rake/rspec not present, skipping this definition
end

