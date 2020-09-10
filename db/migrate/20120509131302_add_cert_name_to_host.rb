class AddCertNameToHost < ActiveRecord::Migration[4.2]
  def up
    add_column :hosts, :certname, :string, :limit => 255
    add_index "hosts", :certname
  end

  def down
    remove_index "hosts", :certname
    remove_column :hosts, :certname
  end
end
