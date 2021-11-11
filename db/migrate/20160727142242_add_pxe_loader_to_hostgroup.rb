class AddPxeLoaderToHostgroup < ActiveRecord::Migration[4.2]
  def change
    add_column :hostgroups, :pxe_loader, :string, :limit => 255
  end
end
