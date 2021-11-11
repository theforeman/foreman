class AddDefaultValueForBookmarkPublicField < ActiveRecord::Migration[4.2]
  def up
    change_column :bookmarks, :public, :boolean, :default => false, :null => false
  end

  def down
    change_column :bookmarks, :public, :boolean, :default => true
  end
end
