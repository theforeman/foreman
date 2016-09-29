class RemoveFailedReportSetting < ActiveRecord::Migration
  class FakeSetting < ActiveRecord::Base
    self.table_name = 'settings'
  end

  def up
    FakeSetting.delete_all(:name => 'failed_report_email_notification')
  end

  def down
    # settings would be created by Setting on code version that uses it
  end
end
