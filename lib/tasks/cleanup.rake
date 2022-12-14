require 'cleanup_helper'

# TRANSLATORS: do not translate
desc <<~END_DESC
  Purge data left over after extraction of some funcionalities.
END_DESC

namespace :purge do
  desc 'Clean up foreman_docker data'
  task foreman_docker: :environment do
    ::CleanupHelper.clean_foreman_docker
  end

  desc 'Clean up all Trends data'
  task trends: :environment do
    success = ::CleanupHelper.clean_trends
    raise("Trends data could not be purged") unless success
  end

  task puppet: :environment do
    success = ::CleanupHelper.clean_puppet
    raise("Puppet data could not be purged") unless success
  end

  task all: ['purge:foreman_docker', 'purge:trends', 'purge:puppet']
end
task purge_data: 'purge:all'
