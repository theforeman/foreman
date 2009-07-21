class CreateArchitectures < ActiveRecord::Migration
  def self.up
    create_table :architectures do |t|
      t.string   "name", :limit => 10, :default => "x86_64", :null => false
      t.timestamps
    end

    create_table :architectures_operatingsystems, :id => false do |t|
      t.references :architecture, :null => false
      t.references :operatingsystem, :null => false
    end

    Architecture.create :name => "x86_64"
    Architecture.create :name => "i386"
  end

  def self.down
    drop_table :architectures
    drop_table :architectures_operatingsystems
  end
end
