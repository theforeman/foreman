namespace :webpack do
  desc 'Compile webpack assets for integration tests'
  task :compile do
    puts 'WARNING: `rake webpack:compile` is deprecated use `rake webpacker:compile` instead.'
    Rake::Task['webpacker:compile'].invoke
  end

  desc 'Try to compile webpack assets for integration tests, fails only with a warning'
  task :try_compile do
    begin
      Rake::Task['webpacker:compile'].invoke
    rescue => e
      puts "WARNING: `rake webpacker:compile` failed to run. This is only important if running integration tests. (cause: #{e})"
    end
  end
end
