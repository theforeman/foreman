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

def log_skip_plugin(plugin_name, reason)
  STDERR.puts "Skipping plugin #{plugin_name}: #{reason}"
end

def log_plugin(plugin_name)
  STDERR.puts "Processing plugin #{plugin_name}"
end

def entry_name(plugin_name, entry)
  prefix = File.basename(entry).gsub(/[_]?index.js$/, '')
  if prefix != ''
    "#{plugin_name}:#{prefix}"
  else
    plugin_name
  end
end

config = { entries: {}, paths: [], plugins: {} }
entry_paths = []
plugin_name_regexp = /foreman.*|katello.*/
specs.each do |dep|
  # skip other rails engines that are not plugins
  # TODO: Consider using the plugin registration api?
  next unless dep.name =~ plugin_name_regexp
  next if dep.name =~ /.*[_-]core$/
  dep = dep.to_spec if gemfile_in

  path = "#{dep.to_spec.full_gem_path}/webpack"

  unless Dir.exist?(path)
    log_skip_plugin(dep.name, './webpack directory missing')
    next
  end
  unless File.exist?("#{dep.to_spec.full_gem_path}/package.json")
    log_skip_plugin(dep.name, './package.json missing')
    next
  end
  log_plugin(dep.name)

  package_json = JSON.parse(File.read("#{dep.to_spec.full_gem_path}/package.json"))

  entries = Dir["#{path}/*index.js"]
  entries << package_json['main'] if package_json['main']

  entries.uniq.each do |entry|
    # some plugins share the same base directory (tasks-core and tasks, REX etc)
    # skip the plugin if its path is already included
    next if entry_paths.include?(entry)
    if File.exist?(entry)
      config[:entries][entry_name(dep.name, entry)] = entry
      config[:paths] << path
      config[:plugins][entry_name(dep.name, entry)] = {root: dep.to_spec.full_gem_path, entry: entry}
      entry_paths << entry
    end
  end
end
config[:paths].uniq!

puts config.to_json
