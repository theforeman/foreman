#! /usr/bin/env ruby

require 'json'

if File.exist?(File.expand_path(File.join(%w[.. .. Gemfile.in]), __FILE__))
  require 'bundler_ext'
  gemfile_in = File.expand_path(File.join(%w[.. .. Gemfile.in]), __FILE__)
  specs = BundlerExt::Gemfile.parse(gemfile_in, :all).map { |spec, value| value[:dep] }
else
  require 'bundler'
  begin
    specs = Bundler.load.specs
  rescue Bundler::GemNotFound
    raise if File.exist?(File.expand_path(File.join(%w[.. Gemfile.lock]), __dir__))
    specs = []
  end
end

config = { entries: {}, paths: [], plugins: {} }
plugin_name_regexp = /foreman*|katello*/
specs.each do |dep|
  # skip other rails engines that are not plugins
  # TODO: Consider using the plugin registration api?
  next unless dep.name =~ plugin_name_regexp
  next if dep.name.include?('_core')
  dep = dep.to_spec if gemfile_in

  path = "#{dep.to_spec.full_gem_path}/webpack"
  # some plugins share the same base directory (tasks-core and tasks, REX etc)
  # skip the plugin if its path is already included
  next if config[:paths].include?(path)
  next unless Dir.exist?(path)
  next unless File.exist?("#{dep.to_spec.full_gem_path}/package.json")
  package_json = JSON.parse(File.read("#{dep.to_spec.full_gem_path}/package.json"))
  main = package_json['main'] || 'index.js'
  entry = "#{path}/#{main}"
  if File.exist?(entry)
    config[:entries][dep.name] = entry
    config[:paths] << path
    config[:plugins][dep.name] = {root: dep.to_spec.full_gem_path, entry: entry}
  end
end

puts config.to_json
