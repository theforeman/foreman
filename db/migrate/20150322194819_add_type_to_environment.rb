class AddTypeToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :type, :string, :null => false, :default => 'PuppetEnvironment'
  end

  def self.down
    remove_column :environments, :type
  end
end
