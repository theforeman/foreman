class AddIndexReportsOnHostIdTypeId < ActiveRecord::Migration
  def change
    add_index :reports, [:host_id, :type, :id]
  end
end
