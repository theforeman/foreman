class DropSmartVariablePermissions < ActiveRecord::Migration[5.2]
  def change
    Permission.where(resource_type: 'VariableLookupKey').destroy_all
  end
end
