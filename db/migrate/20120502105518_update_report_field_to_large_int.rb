class UpdateReportFieldToLargeInt < ActiveRecord::Migration
  def self.up
    change_column :reports, :status, :bigint
    change_column :hosts, :puppet_status, :bigint
  end

  def self.down
  end
end
