class CreateParameters < ActiveRecord::Migration
  def up
    create_table :parameters do |t|
      t.string :name, :value, :limit => 255
      t.references :host
      t.timestamps
    end
  end

  def down
    drop_table :parameters
  end
end
