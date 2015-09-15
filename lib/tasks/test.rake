namespace :test do
  desc "Test API"
  Rake::TestTask.new(:api) do |t|
    t.libs << "test"
    t.pattern = 'test/functional/api/**/*_test.rb'
    t.verbose = true
  end
end

namespace :test do
  desc "Test lib source"
  Rake::TestTask.new(:lib) do |t|
    t.libs << "test"
    t.pattern = 'test/lib/**/*_test.rb'
    t.verbose = true
  end
end

Rake::Task[:test].enhance do
  Rake::Task['test:lib'].invoke
end
