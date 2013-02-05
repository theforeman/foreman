class AddTableBookmarks < ActiveRecord::Migration
  class Bookmark < ActiveRecord::Base; end

  def self.up
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

    User.unscoped.as :admin do
      Bookmark.find_or_create_by_name :name => "eventful", :query => "eventful = true", :controller=> "reports", :public => true
      Bookmark.find_or_create_by_name :name => "active", :query => 'last_report > "35 minutes ago" and (status.applied > 0 or status.restarted > 0)', :controller=> "hosts", :public => true
      Bookmark.find_or_create_by_name :name => "out of sync", :query => 'last_report < "30 minutes ago" and status.enabled = true', :controller=> "hosts", :public => true
      Bookmark.find_or_create_by_name :name => "error", :query => 'last_report > "35 minutes ago" and (status.failed > 0 or status.failed_restarts > 0 or status.skipped > 0)', :controller=> "hosts", :public => true
      Bookmark.find_or_create_by_name :name => "disabled", :query => 'status.enabled = false', :controller=> "hosts", :public => true
    end

  end

  def self.down
    drop_table :bookmarks
  end
end
