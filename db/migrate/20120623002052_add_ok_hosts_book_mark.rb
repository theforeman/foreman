class AddOkHostsBookMark < ActiveRecord::Migration
  def self.up
     Bookmark.find_or_create_by_name_and_query_and_controller :name => "ok hosts", :query => 'last_report > "35 minutes ago" and status.enabled = true and status.applied = 0 and status.failed = 0 and status.pending = 0', :controller=> "hosts", :public => true
  end

  def self.down
  end
end
