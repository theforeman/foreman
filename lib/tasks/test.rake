require 'rake/testtask'

namespace :test do
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
end
