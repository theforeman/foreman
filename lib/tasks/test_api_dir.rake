namespace :test do

  desc "Test API"
  Rake::TestTask.new(:api) do |t|
    t.libs << "test"
    t.pattern = 'test/functional/api/**/*_test.rb'
    t.verbose = true
  end

end
