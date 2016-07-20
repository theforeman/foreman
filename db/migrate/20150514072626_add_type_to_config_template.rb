class AddTypeToConfigTemplate < ActiveRecord::Migration[4.2]
  def change
    add_column :config_templates, :type, :string, :default => 'ConfigTemplate', :limit => 255
    rename_table :config_templates, :templates
  end
end
