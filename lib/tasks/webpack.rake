namespace :webpack do
  # TODO: remove after migrating away from webpack-rails (after setting the
  # max_old_space_size) in other tool.
  desc <<-EOF.strip_heredoc
  Compile webpack bundles: overriding the rake task from webpack-rails to be
  able to set the max_old_space_size option.
  EOF
  task compile: :environment do
    ENV["TARGET"] = 'production' # TODO: Deprecated, use NODE_ENV instead
    ENV["NODE_ENV"] ||= 'production'
    webpack_bin = ::Rails.root.join(::Rails.configuration.webpack.binary)
    config_file = ::Rails.root.join(::Rails.configuration.webpack.config_file)
    max_old_space_size = "2048"

    unless File.exist?(webpack_bin)
      raise "Can't find our webpack executable at #{webpack_bin} - have you run `npm install`?"
    end

    unless File.exist?(config_file)
      raise "Can't find our webpack config file at #{config_file}"
    end

    sh "node --max_old_space_size=#{max_old_space_size} #{webpack_bin} --config #{config_file} --bail"
  end

  desc 'Try to compile webpack assets for integration tests, fails only with a warning'
  task :try_compile do
    begin
      Rake::Task['webpack:compile'].invoke
    rescue => e
      puts "WARNING: `rake webpack:compile` failed to run. This is only important if running integration tests. (cause: #{e})"
    end
  end
end
