class AddIndexToReports < ActiveRecord::Migration
  def up
    add_index :reports, [:reported_at, :host_id]
  end

  def down
    remove_index :reports, [:reported_at, :host_id]
  end
end
