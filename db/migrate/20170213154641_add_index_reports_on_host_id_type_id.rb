class AddIndexReportsOnHostIdTypeId < ActiveRecord::Migration[4.2]
  def change
    add_index :reports, [:host_id, :type, :id]
  end
end
