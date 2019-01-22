class RenameHostStatusesReport < ActiveRecord::Migration[5.2]
  def up
    ReportTemplate.skip_permission_check do
      ReportTemplate.unscoped.where(:name => 'Host statuses CSV').update_all(:name => 'Host statuses')
    end
  end

  def down
    ReportTemplate.skip_permission_check do
      ReportTemplate.unscoped.where(:name => 'Host statuses').update_all(:name => 'Host statuses CSV')
    end
  end
end
