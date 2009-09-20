class AddIndexToReports < ActiveRecord::Migration
  def self.up
     add_index :reports, [:reported_at, :host_id]
  end

  def self.down
     remove_index :reports, [:reported_at, :host_id]
  end
end
