class CreateFilters < ActiveRecord::Migration[4.2]
  def change
    create_table :filters do |t|
      t.text :search
      t.integer :role_id

      t.timestamps null: true
    end
  end
end
