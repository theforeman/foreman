class IndexForeignKeysInConfigGroupClasses < ActiveRecord::Migration[5.1]
  def change
    add_index :config_group_classes, :config_group_id
    add_index :config_group_classes, :puppetclass_id
  end
end
