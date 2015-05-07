class CreateTrends < ActiveRecord::Migration
  def up
    create_table :trends do |t|
      t.string :trendable_type
      t.integer :trendable_id
      t.string :name
      t.string :type
      t.string :fact_value
      t.string :fact_name

      t.timestamps
    end
    add_index :trends, :type
    add_index :trends, [:trendable_type, :trendable_id]
    add_index :trends, :fact_value
  end

  def down
    remove_index :trends, :type
    remove_index :trends, [:trendable_type, :trendable_id]
    remove_index :trends, :fact_value

    drop_table :trends
  end
end
