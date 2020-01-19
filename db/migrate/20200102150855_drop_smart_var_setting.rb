class DropSmartVarSetting < ActiveRecord::Migration[5.2]
  def up
    Setting.where(name: 'Enable_Smart_Variables_in_ENC').delete_all
  end

  def down
  end
end
