class DropViewBookmarksPermission < ActiveRecord::Migration[6.0]
  def up
    Permission.where(name: 'view_bookmarks').destroy_all
    # clean up any empty filters left behind
    Filter.where.not(id: Filtering.distinct.select(:filter_id)).destroy_all
  end

  def down
    # Will be recreated automatically by seeds
  end
end
