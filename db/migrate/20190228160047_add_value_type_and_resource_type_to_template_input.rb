class AddValueTypeAndResourceTypeToTemplateInput < ActiveRecord::Migration[5.2]
  def change
    add_column :template_inputs, :value_type, :string, :default => 'plain', :null => false
    add_column :template_inputs, :resource_type, :string
  end
end
