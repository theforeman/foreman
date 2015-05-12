begin
  require "ci/reporter/rake/minitest"

  namespace :foreman do
    task :set_test_runner do
      ENV['TESTOPTS'] = "#{ENV['TESTOPTS']} #{Rails.root}/test/test_runner.rb"
    end
  end

  namespace :jenkins do
    task :unit do
      system "bundle exec rake db:drop db:create db:migrate RAILS_ENV=test"
      system "rake jenkins:setup:minitest test RAILS_ENV=test"
      exit($?.exitstatus)
    end

    task :integration do
      system "rake test:integration RAILS_ENV=test"
      exit($?.exitstatus)
    end

    task :lib do
      system "rake test:lib RAILS_ENV=test"
      exit($?.exitstatus)
    end

    task :functionals do
      system "rake test:functionals RAILS_ENV=test"
      exit($?.exitstatus)
    end

    task :units do
      system "rake test:units RAILS_ENV=test"
      exit($?.exitstatus)
    end

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
