class AddIndexToLogsSourceId < ActiveRecord::Migration[4.2]
  def up
    add_index :logs, :source_id
  end

  def down
    remove_index :logs, :source_id
  end
end
