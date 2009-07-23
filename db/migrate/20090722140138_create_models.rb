class CreateModels < ActiveRecord::Migration
  def self.up
    create_table :models do |t|
      t.string :name, :limit => 64, :null => false
      t.text :info
      t.timestamps
    end

    add_column :hosts, :model_id, :integer
  end

  def self.down
    drop_table :models
    remove_column :hosts, :model_id
  end
end
