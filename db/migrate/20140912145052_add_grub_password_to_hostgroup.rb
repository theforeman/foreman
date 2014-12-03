class AddGrubPasswordToHostgroup < ActiveRecord::Migration
  def change
    add_column :hostgroups, :grub_pass, :string, :default => ""
  end
end
