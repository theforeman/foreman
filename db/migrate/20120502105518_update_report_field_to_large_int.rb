class UpdateReportFieldToLargeInt < ActiveRecord::Migration
  def up
    change_column :reports, :status, :bigint
    change_column :hosts, :puppet_status, :bigint
  end

  def down
  end
end
