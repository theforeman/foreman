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

# Ensure webpack files are compiled in case integration tests are executed
unless ENV['SKIP_WEBPACK']
  Rake::Task[:test].enhance ['webpack:try_compile'] do
    Rake::FileUtilsExt.verbose(false)
  end
end
