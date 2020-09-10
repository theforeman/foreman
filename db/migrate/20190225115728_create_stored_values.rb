class CreateStoredValues < ActiveRecord::Migration[5.2]
  def change
    create_table :stored_values do |t|
      t.string :key, null: false
      t.index  :key, unique: true
      t.binary :value
      t.datetime :expire_at

      t.timestamps
    end
  end
end
