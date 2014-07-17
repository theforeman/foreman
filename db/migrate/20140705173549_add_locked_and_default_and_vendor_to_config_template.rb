class AddLockedAndDefaultAndVendorToConfigTemplate < ActiveRecord::Migration
  def change 
    add_column :config_templates, :locked, :boolean, :default => false
    # Default indicates templates the come from the provider, e.g. Foreman or Katello
    add_column :config_templates, :default, :boolean, :default => false
    add_column :config_templates, :vendor, :string
  end
end
