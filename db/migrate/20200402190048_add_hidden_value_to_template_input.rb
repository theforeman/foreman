class AddHiddenValueToTemplateInput < ActiveRecord::Migration[5.2]
  def change
    add_column :template_inputs, :hidden_value, :boolean, default: false, null: false
  end
end
