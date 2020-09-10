class AddGrubPasswordToHostgroup < ActiveRecord::Migration[4.2]
  def change
    add_column :hostgroups, :grub_pass, :string, :default => "", :limit => 255
  end
end
