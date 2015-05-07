class CreateHostClass < ActiveRecord::Migration
  def up
    rename_table :hosts_puppetclasses, :host_classes
    add_column :host_classes, :id, :primary_key
  end

  def down
    remove_column :host_classes, :id
    rename_table :host_classes, :hosts_puppetclasses
  end
end
