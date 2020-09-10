class ChangeReportedAt < ActiveRecord::Migration[4.2]
  def up
    Report.where(:reported_at => nil).update_all(:reported_at => Time.at(0).utc)
    change_column :reports, :reported_at, :datetime, :null => false
  end

  def down
    change_column :reports, :reported_at, :datetime, :null => true
  end
end
