class CreateTrends < ActiveRecord::Migration[4.2]
  def up
    create_table :trends do |t|
      t.string :trendable_type, :limit => 255
      t.integer :trendable_id
      t.string :name, :limit => 255
      t.string :type, :limit => 255
      t.string :fact_value, :limit => 255
      t.string :fact_name, :limit => 255

      t.timestamps null: true
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
