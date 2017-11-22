class CreateFilterings < ActiveRecord::Migration[4.2]
  def change
    create_table :filterings do |t|
      t.integer :filter_id
      t.integer :permission_id

      t.timestamps null: true
    end

    add_index :filterings, :filter_id
    add_index :filterings, :permission_id
  end
end
