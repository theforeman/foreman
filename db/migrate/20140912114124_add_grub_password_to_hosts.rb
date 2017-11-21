class AddGrubPasswordToHosts < ActiveRecord::Migration[4.2]
  def change
    add_column :hosts, :grub_pass, :string, :default => "", :limit => 255
  end
end
