class DropPuppetRun < ActiveRecord::Migration[5.2]
  def up
    Setting.where(:name => 'puppetrun').destroy_all
    Permission.where(:name => 'puppetrun_hosts').destroy_all
  end
end
