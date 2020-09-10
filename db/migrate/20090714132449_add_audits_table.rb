class AddAuditsTable < ActiveRecord::Migration[4.2]
  def up
    create_table :audits, :force => true do |t|
      t.column :auditable_id, :integer
      t.column :auditable_type, :string, :limit => 255
      t.column :user_id, :integer
      t.column :user_type, :string, :limit => 255
      t.column :username, :string, :limit => 255
      t.column :action, :string, :limit => 255
      t.column :changes, :text
      t.column :version, :integer, :default => 0
      t.column :comment, :string, :limit => 255
      t.column :auditable_parent_id, :integer
      t.column :auditable_parent_type, :string, :limit => 255
      t.column :request_uuid, :string, :limit => 255
      t.column :created_at, :datetime
    end

    add_index :audits, [:auditable_id, :auditable_type], :name => 'auditable_index'
    add_index :audits, [:user_id, :user_type], :name => 'user_index'
    add_index :audits, :created_at
    add_index :audits, [:auditable_parent_id, :auditable_parent_type], :name => 'auditable_parent_index'
  end

  def down
    drop_table :audits
  end
end
