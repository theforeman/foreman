class AddAliasesToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :aliases, :string, :default => ""
  end
end
