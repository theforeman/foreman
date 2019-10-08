class AddDefaultToTemplateInputs < ActiveRecord::Migration[5.2]
  def change
    add_column :template_inputs, :default, :string
  end
end
