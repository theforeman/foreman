class AddIndexToLogsSourceId < ActiveRecord::Migration
  def up
    add_index :logs, :source_id
  end

  def down
    remove_index :logs, :source_id
  end
end
