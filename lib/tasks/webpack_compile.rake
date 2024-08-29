namespace :webpack do
  # TODO: remove after migrating away from webpack-rails (after setting the
  # max_old_space_size) in other tool.
  desc <<~EOF
    Compile webpack bundles: overriding the rake task from webpack-rails to be
    able to set the max_old_space_size option.
  EOF
  task compile: :environment do
    ENV["TARGET"] = 'production' # TODO: Deprecated, use NODE_ENV instead
    ENV["NODE_ENV"] ||= 'production'
    config_file = ::Rails.root.join('config/webpack.config.js')
    max_old_space_size = "2048"

    unless File.exist?(config_file)
      raise "Can't find our webpack config file at #{config_file}"
    end

    sh "npx --max_old_space_size=#{max_old_space_size} webpack --config #{config_file} --bail"
    ActiveRecord::Base.clear_all_connections!
  end
end
