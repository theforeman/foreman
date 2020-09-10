class CreateSources < ActiveRecord::Migration[4.2]
  def up
    create_table :sources do |t|
      t.text :value
    end
    add_index :sources, :value
  end

  def down
    remove_index :sources, :value
    drop_table :sources
  end
end
