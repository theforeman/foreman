class MigrateInstallationMediumUri < ActiveRecord::Migration
  def up
    Medium.unscoped.all.each do |medium|
      matches = /^([^:]+):(\/.+)/.match(medium.path)

      if matches.size == 3 && ![ 'http', 'https', 'ftp', 'ftps', 'nfs' ].include?(matches[1])
        medium.path = 'nfs://' + matches[1] + matches[2]
        medium.save
      end
    end
  end

  def down
  end
end
