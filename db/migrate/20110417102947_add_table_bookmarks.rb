class AddTableBookmarks < ActiveRecord::Migration[4.2]
  def up
    create_table :bookmarks, :force => true do |t|
      t.column :name, :string, :limit => 255
      t.column :query, :string, :limit => 255
      t.column :controller, :string, :limit => 255
      t.column :public, :boolean
      t.column :owner_id, :integer
      t.column :owner_type, :string, :limit => 255
    end

    add_index :bookmarks, :name
    add_index :bookmarks, :controller
    add_index :bookmarks, [:owner_id, :owner_type]
  end

  def down
    drop_table :bookmarks
  end
end
