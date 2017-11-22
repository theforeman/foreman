class CreateTrendCounters < ActiveRecord::Migration[4.2]
  def up
    create_table :trend_counters do |t|
      t.integer :trend_id
      t.integer :count

      t.timestamps null: true
    end
    add_index :trend_counters, :trend_id
  end

  def down
    remove_index :trend_counters, :trend_id
    drop_table :trend_counters
  end
end
