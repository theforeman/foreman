class CreateLogs < ActiveRecord::Migration
  def up
    create_table :logs do |t|
      t.integer :source_id
      t.integer :message_id
      t.integer :report_id
      t.integer :level_id

      t.timestamps
    end
    add_index :logs, :report_id
    add_index :logs, :message_id
    add_index :logs, :level_id
  end

  def down
    remove_index :logs, :level_id
    remove_index :logs, :report_id
    remove_index :logs, :message_id
    drop_table :logs
  end
end
