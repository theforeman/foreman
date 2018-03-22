class RemoveFailedReportSetting < ActiveRecord::Migration[4.2]
  class FakeSetting < ApplicationRecord
    self.table_name = 'settings'
  end

  def up
    FakeSetting.where(:name => 'failed_report_email_notification').delete_all
  end

  def down
    # settings would be created by Setting on code version that uses it
  end
end
