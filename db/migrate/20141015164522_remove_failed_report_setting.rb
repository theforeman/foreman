class RemoveFailedReportSetting < ActiveRecord::Migration
  class FakeSetting < ApplicationRecord
    self.table_name = 'settings'
  end

  def up
    FakeSetting.delete_all(:name => 'failed_report_email_notification')
  end

  def down
    # settings would be created by Setting on code version that uses it
  end
end
