class IndexForeignKeysInEnvironmentClasses < ActiveRecord::Migration[5.1]
  def change
    add_index :environment_classes, :puppetclass_lookup_key_id
  end
end
