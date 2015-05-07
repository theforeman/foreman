class ChangeBookmarkColumnToText < ActiveRecord::Migration
  def up
    change_column 'bookmarks', :query, :text
  end

  def down
    change_column 'bookmarks', :query, :string
  end
end

