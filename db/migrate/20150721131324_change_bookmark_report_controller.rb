class ChangeBookmarkReportController < ActiveRecord::Migration
  def up
    bookmarks_with_report_controller = Bookmark.where(:controller => 'reports')
    bookmarks_with_report_controller.update_all("controller = 'config_reports'")
  end

  def down
    bookmarks_with_config_report_controller = Bookmark.where(:controller => 'config_reports')
    bookmarks_with_config_report_controller.update_all("controller = 'reports'")
  end
end
