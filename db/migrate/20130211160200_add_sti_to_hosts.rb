class AddStiToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :type, :string
    execute "UPDATE hosts set type='Host::Managed'"
    add_index :hosts, :type
  end

  def self.down
    remove_column :hosts, :type
  end
end
