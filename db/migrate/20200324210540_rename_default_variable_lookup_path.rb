class RenameDefaultVariableLookupPath < ActiveRecord::Migration[5.2]
  def up
    old_setting_val = Setting.where(name: 'Default_variables_Lookup_Path')
    return unless old_setting_val.exists?
    Setting.where(name: 'Default_parameters_Lookup_Path').
            update_all(value: old_setting_val.pick(:value))
    old_setting_val.delete_all
  end
end
