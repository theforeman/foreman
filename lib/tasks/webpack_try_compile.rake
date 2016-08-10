namespace :webpack do
  desc 'Try to compile webpack assets for integration tests, fails only with a warning'
  task :try_compile do
    begin
      Rake::Task['webpack:compile'].invoke
    rescue => e
      puts "WARNING: `rake webpack:compile` failed to run. This is only important if running integration tests. (cause: #{e})"
    end
  end
end
