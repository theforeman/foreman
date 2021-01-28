class DropPuppetRun < ActiveRecord::Migration[5.2]
  def up
    Setting.where(:name => 'puppetrun').delete_all
    Permission.where(:name => 'puppetrun_hosts').destroy_all
  end
end
