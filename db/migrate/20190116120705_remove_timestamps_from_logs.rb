class RemoveTimestampsFromLogs < ActiveRecord::Migration[5.2]
  def change
    remove_column :logs, :created_at, :datetime
    remove_column :logs, :updated_at, :datetime
  end
end
