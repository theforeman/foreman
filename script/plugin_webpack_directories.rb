#! /usr/bin/env ruby

require 'json'
require_relative '../app/registries/foreman/webpack_assets'

if File.exist?(File.expand_path(File.join(%w[.. .. Gemfile.in]), __FILE__))
  require 'bundler_ext'
  gemfile_in = File.expand_path(File.join(%w[.. .. Gemfile.in]), __FILE__)
  specs = BundlerExt::Gemfile.parse(gemfile_in, :all).map { |spec, value| value[:dep] }
else
  require 'bundler'
  specs = Bundler.load.specs
end

include Foreman::WebpackAssets

config = { entries: {}, paths: [] }
specs.each do |dep|
  # skip other rails engines that are not plugins
  # TODO: Consider using the plugin registration api?
  if gemfile_in
    next unless dep =~ plugin_name_regexp
    dep = dep.to_spec
  else
    next unless dep.name =~ plugin_name_regexp
  end

  path = "#{dep.to_spec.full_gem_path}/webpack"
  entry = "#{path}/index.js"
  # some plugins share the same base directory (tasks-core and tasks, REX etc)
  # skip the plugin if its path is already included
  next if config[:paths].include?(path)
  if File.exist?(entry)
    config[:entries][bundle_name dep.name] = entry
    config[:paths] << path
  end
end

puts config.to_json
