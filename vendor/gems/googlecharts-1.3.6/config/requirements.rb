require 'fileutils'
include FileUtils

require 'rubygems'
%w[rake hoe newgem rubigen].each do |req_gem|
  begin
    require req_gem
  rescue LoadError
    puts "This Rakefile could use '#{req_gem}' RubyGem."
    puts "Installation: gem install #{req_gem} -y"
  end
end

$:.unshift(File.join(File.dirname(__FILE__), %w[.. lib]))

require 'gchart'