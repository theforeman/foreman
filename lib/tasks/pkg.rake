require 'fileutils'

namespace :pkg do
  desc 'Create DEB package with `debuild`.'
  task :deb do
    # copy 'debian' directory from 'extras' into main directory
    FileUtils.cp_r 'extras/debian/', Rake.application.original_dir + '/debian'

    # run 'debuild'
    system 'debuild'

    if $? == 0
      # remove 'debian' directory
      FileUtils.rm_r Rake.application.original_dir + '/debian', :force => true
    else
      abort 'Error while building the DEB package with `debuild`. Please check the output.'
    end
  end

  desc 'Generate package source tar.bz2, supply ref=<tag> for tags'
  task :generate_source do
    File.exist?('pkg') || FileUtils.mkdir('pkg')
    ref = ENV['ref'] || 'HEAD'
    version = `git show #{ref}:VERSION`.chomp.chomp('-develop')
    raise "can't find VERSION from #{ref}" if version.length == 0
    `git archive --prefix=foreman-#{version}/ #{ref} | bzip2 -9 > pkg/foreman-#{version}.tar.bz2`
  end
end
