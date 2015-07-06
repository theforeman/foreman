class ChangeReportPermissions < ActiveRecord::Migration
  PERMISSIONS = %w(view_reports destroy_reports upload_reports)
  def up
    old_name = 'Report'
    new_name = 'ConfigReport'
    Permission.update_all("resource_type = '#{new_name}'", "resource_type = '#{old_name}'")
    PERMISSIONS.each do |from|
      to = from.sub('reports', 'config_reports')
      say "renaming permission #{from} to #{to}"
      Permission.update_all("name = '#{to}'", "name = '#{from}'")
    end
  end

  def down
    old_name = 'ConfigReport'
    new_name = 'Report'
    Permission.update_all("resource_type = '#{new_name}'", "resource_type = '#{old_name}'")
    PERMISSIONS.each do |from|
      to = from.sub('config_reports', 'reports')
      say "renaming permission #{from} to #{to}"
      Permission.update_all("name = '#{to}'", "name = '#{from}'")
    end
  end
end
