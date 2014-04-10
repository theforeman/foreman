class CreateHostConfigGroups < ActiveRecord::Migration
  def change
    create_table :host_config_groups do |t|
      t.integer :config_group_id
      t.integer :host_id
      t.string  :host_type

      t.timestamps
    end
  end
end
