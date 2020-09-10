class RenameDefaultVariableLookupPath < ActiveRecord::Migration[5.2]
  def up
    old_setting = Setting.find_by :name => 'Default_variables_Lookup_Path'
    new_setting = Setting.find_by :name => 'Default_parameters_Lookup_Path'
    return unless old_setting.present? && new_setting.present?
    new_setting.update_attribute(
      :value,
      old_setting.value
    )
    old_setting.destroy
  end
end
