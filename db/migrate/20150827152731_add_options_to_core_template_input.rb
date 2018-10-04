class AddOptionsToCoreTemplateInput < ActiveRecord::Migration[4.2]
  def change
    return if column_exists?(:template_inputs, :options)
    add_column :template_inputs, :options, :text
  end
end
