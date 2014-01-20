class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.text :search
      t.integer :role_id

      t.timestamps
    end
  end
end
