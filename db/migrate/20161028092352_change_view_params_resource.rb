class ChangeViewParamsResource < ActiveRecord::Migration
  def up
    view_params = Permission.where(:name => ['view_params', 'edit_params', 'create_params', 'destroy_params'])
    view_params.each do |permission|
      permission.update_attribute(:resource_type, 'LookupValue')
    end
  end

  def down
    view_params = Permission.where(:name => ['view_params', 'edit_params', 'create_params', 'destroy_params'])
    view_params.each do |permission|
      permission.update_attribute(:resource_type, 'Parameter')
    end
  end
end
