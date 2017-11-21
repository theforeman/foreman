class CreateModels < ActiveRecord::Migration[4.2]
  def up
    create_table :models do |t|
      t.string :name, :limit => 64, :null => false
      t.text :info
      t.timestamps null: true
    end

    add_column :hosts, :model_id, :integer
  end

  def down
    drop_table :models
    remove_column :hosts, :model_id
  end
end
