class CreateTrendCounters < ActiveRecord::Migration
  def self.up
    create_table :trend_counters do |t|
      t.integer :trend_id
      t.integer :count

      t.timestamps
    end
    add_index :trend_id
  end

  def self.down
    drop_table :trend_counters
  end
end
