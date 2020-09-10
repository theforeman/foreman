class CreateSessions < ActiveRecord::Migration[4.2]
  def up
    create_table :sessions do |t|
      t.string :session_id, :null => false, :limit => 255
      t.text :data
      t.timestamps null: true
    end

    add_index :sessions, :session_id
    add_index :sessions, :updated_at
  end

  def down
    drop_table :sessions
  end
end
