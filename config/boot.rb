require 'rubygems'

unless File.exist?(File.expand_path('../Gemfile.in', __dir__))
  ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
  # Set up boootsnap on Ruby 2.3+ in development env with Bundler enabled and development group
  early_env = ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
  require 'active_support/dependencies'
  require('bootsnap/setup') if early_env == "development" && File.exist?(ENV['BUNDLE_GEMFILE']) && !Gem::Specification.stubs_for("bootsnap").empty?
end
