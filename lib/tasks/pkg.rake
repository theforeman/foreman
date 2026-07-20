require 'English'
require 'fileutils'

namespace :pkg do
  desc 'Generate package source tar.bz2, supply ref=<tag> for tags'
  task :generate_source do
    File.exist?('pkg') || FileUtils.mkdir('pkg')
    ref = ENV['ref'] || 'HEAD'
    name = 'foreman'
    version = `git show #{ref}:VERSION`.chomp
    raise "can't find VERSION from #{ref}" if version.empty?
    filename = "pkg/#{name}-#{version}.tar.bz2"
    `git archive --prefix=#{name}-#{version}/ #{ref} | bzip2 -9 > #{filename}`
    raise 'Failed to generate the source archive' if $CHILD_STATUS != 0
    puts filename
  end
end
