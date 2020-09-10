class ChangeReportPermissions < ActiveRecord::Migration[4.2]
  PERMISSIONS = %w(view_reports destroy_reports upload_reports)
  def up
    old_name = 'Report'
    new_name = 'ConfigReport'
    Permission.where(:resource_type => new_name).update_all(:resource_type => old_name)
    PERMISSIONS.each do |from|
      to = from.sub('reports', 'config_reports')
      say "renaming permission #{from} to #{to}"
      Permission.where(:name => to).update_all(:name => from)
    end
  end

  def down
    old_name = 'ConfigReport'
    new_name = 'Report'
    Permission.where(:resource_type => new_name).update_all(:resource_type => old_name)
    PERMISSIONS.each do |from|
      to = from.sub('config_reports', 'reports')
      say "renaming permission #{from} to #{to}"
      Permission.where(:name => to).update_all(:name => from)
    end
  end
end
