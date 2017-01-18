class AddTypeIndexToReports < ActiveRecord::Migration
  def change
    add_index :reports, :type
    add_index :reports, [:type, :host_id]
  end
end
