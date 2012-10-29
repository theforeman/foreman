class CreateTrends < ActiveRecord::Migration
  def self.up
    create_table :trends do |t|
      t.string :trendable_type
      t.integer :trendable_id
      t.string :name
      t.string :type
      t.string :fact_value
      t.string :fact_name

      t.timestamps
    end
  end

  def self.down
    drop_table :trends
  end
end
