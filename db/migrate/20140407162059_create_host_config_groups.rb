class CreateHostConfigGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :host_config_groups do |t|
      t.integer :config_group_id
      t.integer :host_id
      t.string  :host_type, :limit => 255

      t.timestamps null: true
    end
  end
end
