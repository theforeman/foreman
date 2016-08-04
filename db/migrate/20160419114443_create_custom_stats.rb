class CreateCustomStats < ActiveRecord::Migration
  def up
    create_table :statistics do |t|
      t.string :name
      t.string :value
      t.timestamps
    end
  end

  def down
    drop_table :statistics
  end
end
