class AddTableBookmarks < ActiveRecord::Migration
  def up
    create_table :bookmarks, :force => true do |t|
      t.column :name, :string
      t.column :query, :string
      t.column :controller, :string
      t.column :public, :boolean
      t.column :owner_id, :integer
      t.column :owner_type, :string
    end

    add_index :bookmarks, :name
    add_index :bookmarks, :controller
    add_index :bookmarks, [:owner_id, :owner_type]
  end

  def down
    drop_table :bookmarks
  end
end
