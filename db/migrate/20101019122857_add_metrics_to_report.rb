class AddMetricsToReport < ActiveRecord::Migration
  def up
    add_column :reports, :metrics, :text
  end

  def down
    remove_column :reports, :metrics
  end
end
