class DebReleaseNameUnknown < ActiveRecord::Migration[5.2]
  def up
    Operatingsystem.where(type: 'Debian', release_name: [nil, '']).update_all(release_name: 'unknown')
  end
end
