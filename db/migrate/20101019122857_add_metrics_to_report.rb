class AddMetricsToReport < ActiveRecord::Migration[4.2]
  def up
    add_column :reports, :metrics, :text
  end

  def down
    remove_column :reports, :metrics
  end
end
