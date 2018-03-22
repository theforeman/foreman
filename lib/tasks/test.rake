require 'rake/testtask'

namespace :test do
  desc "Test API"
  Rake::TestTask.new(:api) do |t|
    t.libs << "test"
    t.pattern = 'test/functional/api/**/*_test.rb'
    t.verbose = true
    t.warning = false
  end
end

# Ensure webpack files are compiled in case integration tests are executed
Rake::Task[:test].enhance ['webpack:try_compile'] do
  Rake::FileUtilsExt.verbose(false)
end
