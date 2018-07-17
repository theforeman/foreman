class AddOptionsToCoreTemplateInput < ActiveRecord::Migration[4.2]
  def change
    add_column :template_inputs, :options, :text
  end
end
