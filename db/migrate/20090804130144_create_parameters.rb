class CreateParameters < ActiveRecord::Migration[4.2]
  def up
    create_table :parameters do |t|
      t.string :name, :value, :limit => 255
      t.references :host
      t.timestamps null: true
    end
  end

  def down
    drop_table :parameters
  end
end
