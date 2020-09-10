class RemoveModulepathSetting < ActiveRecord::Migration[5.1]
  def up
    Setting.where(:name => 'modulepath').delete_all
  end

  def down
    # settings would be created by Setting on code version that uses it
  end
end
