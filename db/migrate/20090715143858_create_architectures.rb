class CreateArchitectures < ActiveRecord::Migration
  def self.up
    create_table :architectures do |t|
      t.string   "name", :limit => 10, :default => "x86_64", :null => false
      t.timestamps
    end
    Architecture.create :name => "x86_64"
    Architecture.create :name => "i386"
  end

  def self.down
    drop_table :architectures
  end
end
