namespace :test do

  desc "Test API"
  Rake::TestTask.new(:api) do |t|
    t.libs << "test"
    t.pattern = 'test/functional/api/v1/*_test.rb'
    t.verbose = true
  end

end
