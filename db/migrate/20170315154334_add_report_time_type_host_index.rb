class AddReportTimeTypeHostIndex < ActiveRecord::Migration
  def change
    add_index :reports, [:reported_at, :host_id, :type]
  end
end
