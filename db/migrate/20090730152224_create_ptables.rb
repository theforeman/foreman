class CreatePtables < ActiveRecord::Migration[4.2]
  class Ptable < ApplicationRecord; end
  def up
    create_table :ptables do |t|
      t.string :name,   :limit => 64, :null => false
      t.string :layout, :limit => 4096, :null => false
      t.references :operatingsystem
      t.timestamps null: true
    end
    create_table :operatingsystems_ptables, :id => false do |t|
      t.references :ptable, :null => false
      t.references :operatingsystem, :null => false
    end
  end

  def down
    drop_table :ptables
    drop_table :operatingsystems_ptables
  end
end
