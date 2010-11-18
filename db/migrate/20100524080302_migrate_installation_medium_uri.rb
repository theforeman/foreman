class MigrateInstallationMediumUri < ActiveRecord::Migration
  def self.up
    Medium.all.each { |medium|
      matches = /^([^:]+):(\/.+)/.match(medium.path)

      if matches.size == 3 and ![ 'http', 'https', 'ftp', 'ftps', 'nfs' ].include?(matches[1])
        medium.path = 'nfs://' + matches[1] + matches[2]
        medium.save
      end
    }
  end

  def self.down
  end
end
