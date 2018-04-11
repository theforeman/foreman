#! /usr/bin/env ruby

require 'json'

if File.exist?(File.expand_path(File.join(%w[.. .. Gemfile.in]), __FILE__))
  require 'bundler_ext'
  gemfile_in = File.expand_path(File.join(%w[.. .. Gemfile.in]), __FILE__)
  specs = BundlerExt::Gemfile.parse(gemfile_in, :all).map { |spec, value| value[:dep] }
else
  require 'bundler'
  specs = Bundler.load.specs
end

config = { entries: {}, paths: [], plugins: {} }
plugin_name_regexp = /foreman*|katello*/
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
  # some plugins share the same base directory (tasks-core and tasks, REX etc)
  # skip the plugin if its path is already included
  next if config[:paths].include?(path)
  if Dir.exist?(path) && !dep.files.any? { |f| f.match?(/webpack/) }
    STDERR.puts "WARNING: webpack was found in #{dep.name}'s source, "\
      "but it's not in the gemspec. Please add it to the gemspec."
  end
  if File.exist?("#{dep.to_spec.full_gem_path}/package.json") &&
      !dep.files.include?('package.json')
    STDERR.puts "WARNING: package.json was found in #{dep.name}'s source, "\
      "but it's not in the gemspec. Please add it to the gemspec."
  end
  next unless dep.files.include? 'package.json'
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
