class AddUniqueConstraintsToFactValues < ActiveRecord::Migration[4.2]
  def up
    add_index(:fact_values, [:fact_name_id, :host_id], :unique => true)
  end

  def down
    remove_index(:fact_values, [:fact_name_id, :host_id])
  end
end
