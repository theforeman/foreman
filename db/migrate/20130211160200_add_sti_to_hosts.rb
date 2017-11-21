class AddStiToHosts < ActiveRecord::Migration[4.2]
  def up
    add_column :hosts, :type, :string, :limit => 255
    execute "UPDATE hosts set type='Host::Managed'"
    add_index :hosts, :type
  end

  def down
    remove_column :hosts, :type
  end
end
