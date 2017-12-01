require 'rubygems'

unless File.exist?(File.expand_path('../../Gemfile.in', __FILE__))
  ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
  # Set up boootsnap on Ruby 2.3+ in development env with Budler enabled and development group
  early_env = ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
  require('bootsnap/setup') if RUBY_VERSION >= '2.3' && early_env == "development" && File.exist?(ENV['BUNDLE_GEMFILE']) && !Gem::Specification.stubs_for("bootsnap").empty?
end
