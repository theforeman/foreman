#!/usr/bin/env ruby

require 'bundler'

# Only works for local dependencies
Bundler.load.specs.select { |dep| dep.name =~ /foreman*/ }.each do |dependency|
  webpack_path = "#{dependency.to_spec.full_gem_path}/webpack"
  puts webpack_path if Dir.exists? webpack_path
end
