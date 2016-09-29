class CreateTrendCounters < ActiveRecord::Migration
  def up
    create_table :trend_counters do |t|
      t.integer :trend_id
      t.integer :count

      t.timestamps
    end
    add_index :trend_counters, :trend_id
  end

  def down
    remove_index :trend_counters, :trend_id
    drop_table :trend_counters
  end
end
