class DropPuppetServerSetting < ActiveRecord::Migration[5.2]
  def up
    Setting.where(:name => 'puppet_server').delete_all
  end

  def down
    # settings would be created by Setting on code version that uses it
  end
end
