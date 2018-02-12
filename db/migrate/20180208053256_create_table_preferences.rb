class CreateTablePreferences < ActiveRecord::Migration[5.1]
  def change
    create_table :table_preferences do |t|
      t.string :name, :limit => 255, :null => false
      t.text :columns
      t.timestamps :null => false
      t.integer :user_id, :null => false
    end
    add_foreign_key :table_preferences, :users, :name => "table_preferences_user_id_fk"
    add_index :table_preferences, [:user_id, :name], :unique => true
  end
end
