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

plugins = {}
plugin_name_regexp = /foreman.*|katello.*/
specs.each do |dep|
  # skip other rails engines that are not plugins
  # TODO: Consider using the plugin registration api?
  next unless dep.name =~ plugin_name_regexp
  next if dep.name =~ /.*[_-]core$/
  dep = dep.to_spec if gemfile_in
  
  plugin_root_path = dep.to_spec.full_gem_path
  plugin_package_json_path = "#{plugin_root_path}/package.json"

  unless File.exist?(plugin_package_json_path)
    log_skip_plugin(dep.name, './package.json missing')
    next
  end

  package_json = JSON.parse(File.read(plugin_package_json_path))
  tfm_build_config = package_json['tfmBuildConfig']
  
  if tfm_build_config.nil?
    log_skip_plugin(dep.name, "no tfmBuildConfig in package.json")
    next
  end
  
  log_plugin(dep.name)
  
  plugins[dep.name] = {
    root: dep.to_spec.full_gem_path,
    config: "#{plugin_root_path}/#{tfm_build_config}"
  }
end

puts plugins.to_json
