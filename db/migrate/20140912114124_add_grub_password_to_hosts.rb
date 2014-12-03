class AddGrubPasswordToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :grub_pass, :string, :default => ""
  end
end
