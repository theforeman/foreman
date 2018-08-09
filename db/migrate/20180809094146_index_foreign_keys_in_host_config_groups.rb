class IndexForeignKeysInHostConfigGroups < ActiveRecord::Migration[5.1]
  def change
    add_index :host_config_groups, :config_group_id
    add_index :host_config_groups, :host_id
  end
end
