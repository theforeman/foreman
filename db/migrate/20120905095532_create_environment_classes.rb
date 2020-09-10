class CreateEnvironmentClasses < ActiveRecord::Migration[4.2]
  class EnvironmentClass < ApplicationRecord; end

  def up
    rename_table :environments_puppetclasses, :environment_classes
    add_column :environment_classes, :id, :primary_key
    add_column :environment_classes, :lookup_key_id, :integer
  end

  def down
    remove_column :environment_classes, :id
    remove_column :environment_classes, :lookup_key_id
    rename_table :environment_classes, :environments_puppetclasses
  end
end
