class ChangeBookmarkColumnToText < ActiveRecord::Migration
  def self.up
    change_column 'bookmarks', :query, :text
  end

  def self.down
    change_column 'bookmarks', :query, :string
  end
end

