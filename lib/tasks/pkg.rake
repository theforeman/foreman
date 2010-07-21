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
end
