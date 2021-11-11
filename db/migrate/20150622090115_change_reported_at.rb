class ChangeReportedAt < ActiveRecord::Migration[4.2]
  def up
    change_column :reports, :reported_at, :datetime, :null => false
  end

  def down
    change_column :reports, :reported_at, :datetime, :null => true
  end
end
