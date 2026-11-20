require 'rake/testtask'

namespace :test do
  desc "Test Presenters, Subscribers and Validators"
  Rake::TestTask.new(:unit_extras) do |t|
    t.libs << "test"
    t.pattern = ['test/{presenters,subscribers,validators}/**/*_test.rb']
    t.verbose = true
    t.warning = false
  end

  desc "Test Services"
  Rake::TestTask.new(:services) do |t|
    t.libs << "test"
    t.pattern = ['test/services/**/*_test.rb']
    t.verbose = true
    t.warning = false
  end

  desc "Test Migrations"
  Rake::TestTask.new(:migrations) do |t|
    t.libs << "test"
    t.pattern = ['test/migrate/**/*_test.rb']
    t.verbose = true
    t.warning = false
  end

  desc "Test API"
  Rake::TestTask.new(:api) do |t|
    t.libs << "test"
    t.pattern = ['test/functional/api/**/*_test.rb', 'test/controllers/api/**/*_test.rb']
    t.verbose = true
    t.warning = false
  end

  desc "Test GraphQL"
  Rake::TestTask.new(:graphql) do |t|
    t.libs << "test"
    t.pattern = ['test/graphql/**/*_test.rb']
    t.verbose = true
    t.warning = false
  end

  desc "Test via external tools"
  Rake::TestTask.new(:external) do |t|
    t.libs << "test"
    t.pattern = ['test/external/**/*_test.rb']
    t.verbose = true
    t.warning = false
  end

  desc "Core tests for plugins"
  Rake::TestTask.new(:core_tests) do |t|
    t.libs << "test"
    t.pattern = ['test/unit/foreman/access_permissions_test.rb']
    t.verbose = true
    t.warning = false
  end
end
