class CreateEnvironmentClasses < ActiveRecord::Migration
  class EnvironmentClass < ActiveRecord::Base; end

  def self.up
    rename_table :environments_puppetclasses, :environment_classes
    add_column :environment_classes, :id, :primary_key
    add_column :environment_classes, :lookup_key_id, :integer
  end

  def self.down
    remove_column :environment_classes, :id
    remove_column :environment_classes, :lookup_key_id
    rename_table :environment_classes, :environments_puppetclasses
  end

end
