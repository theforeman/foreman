class CreateArchitectures < ActiveRecord::Migration[4.2]
  def up
    create_table :architectures do |t|
      t.string   "name", :limit => 10, :default => "x86_64", :null => false
      t.timestamps null: true
    end

    create_table :architectures_operatingsystems, :id => false do |t|
      t.references :architecture, :null => false
      t.references :operatingsystem, :null => false
    end
  end

  def down
    drop_table :architectures
    drop_table :architectures_operatingsystems
  end
end
