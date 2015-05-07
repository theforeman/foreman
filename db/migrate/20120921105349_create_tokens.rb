class CreateTokens < ActiveRecord::Migration
  def up
    create_table :tokens do |t|
      t.string :value
      t.datetime :expires
      t.integer :host_id
    end
    add_index :tokens, :value
    add_index :tokens, :host_id
  end

  def down
    drop_table :tokens
  end
end
