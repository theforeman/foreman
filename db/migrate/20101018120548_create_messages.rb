class CreateMessages < ActiveRecord::Migration[4.2]
  def up
    create_table :messages do |t|
      t.text :value
    end
    add_index :messages, :value
  end

  def down
    remove_index :messages, :value
    drop_table :messages
  end
end
