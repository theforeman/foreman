class UpdateReportFieldToLargeInt < ActiveRecord::Migration[4.2]
  def up
    change_column :reports, :status, :bigint
    change_column :hosts, :puppet_status, :bigint
  end

  def down
  end
end
