class AddReportTimeTypeHostIndex < ActiveRecord::Migration[4.2]
  def change
    add_index :reports, [:reported_at, :host_id, :type]
  end
end
