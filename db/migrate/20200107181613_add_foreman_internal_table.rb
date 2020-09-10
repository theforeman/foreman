class AddForemanInternalTable < ActiveRecord::Migration[5.2]
  def change
    create_table :foreman_internals do |t|
      t.string :key
      t.string :value
      t.timestamps
    end
  end
end
