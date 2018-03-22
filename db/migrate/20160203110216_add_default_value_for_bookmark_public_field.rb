class AddDefaultValueForBookmarkPublicField < ActiveRecord::Migration[4.2]
  def up
    Bookmark.where(:public => nil).update_all(:public => false)
    change_column :bookmarks, :public, :boolean, :default => false, :null => false
  end

  def down
    change_column :bookmarks, :public, :boolean, :default => true
  end
end
