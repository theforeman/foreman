class DropParameterizedClassesSetting < ActiveRecord::Migration[5.2]
  def up
    Setting.where(name: 'Parametrized_Classes_in_ENC').delete_all
  end
end
