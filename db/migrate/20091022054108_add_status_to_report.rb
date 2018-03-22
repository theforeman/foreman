class AddStatusToReport < ActiveRecord::Migration[4.2]
  def up
    add_column :reports, :status, :integer
    add_index :reports, :status
    add_index :reports, :host_id
    add_index :reports, :reported_at
  end

  def down
    remove_index :reports, :status
    remove_index :reports, :host_id
    remove_index :reports, :reported_at
    remove_column :reports, :status
  end
end
