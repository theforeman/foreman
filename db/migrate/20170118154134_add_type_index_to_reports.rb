class AddTypeIndexToReports < ActiveRecord::Migration[4.2]
  def change
    add_index :reports, :type
    add_index :reports, [:type, :host_id]
  end
end
