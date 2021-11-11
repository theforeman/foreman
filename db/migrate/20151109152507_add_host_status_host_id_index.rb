class AddHostStatusHostIdIndex < ActiveRecord::Migration[4.2]
  def up
    add_index :host_status, [:type, :host_id], :unique => true
  end

  def down
    remove_index :host_status, [:type, :host_id]
  end
end
