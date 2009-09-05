class AddTypeToParameter < ActiveRecord::Migration
  def self.up
    add_column :parameters, :type, :string
  end

  def self.down
    remove_column :parameters, :type
  end
end
