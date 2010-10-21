class AddMetricsToReport < ActiveRecord::Migration
  def self.up
    add_column :reports, :metrics, :text
  end

  def self.down
    remove_column :reports, :metrics
  end
end
