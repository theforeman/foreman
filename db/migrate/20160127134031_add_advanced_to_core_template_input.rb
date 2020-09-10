class AddAdvancedToCoreTemplateInput < ActiveRecord::Migration[4.2]
  def up
    add_column :template_inputs, :advanced, :boolean, :default => false, :null => false
  end

  def down
    remove_column :template_inputs, :advanced
  end
end
