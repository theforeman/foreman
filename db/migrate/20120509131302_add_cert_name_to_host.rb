class AddCertNameToHost < ActiveRecord::Migration
  def self.up
    add_column :hosts, :certname, :string
    add_index "hosts", :certname

  end

  def self.down
    remove_index "hosts", :certname
    remove_column :hosts, :certname
  end
end
