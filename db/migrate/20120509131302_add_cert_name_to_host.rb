class AddCertNameToHost < ActiveRecord::Migration
  def up
    add_column :hosts, :certname, :string
    add_index "hosts", :certname
  end

  def down
    remove_index "hosts", :certname
    remove_column :hosts, :certname
  end
end
