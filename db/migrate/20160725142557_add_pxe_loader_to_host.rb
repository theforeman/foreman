class AddPxeLoaderToHost < ActiveRecord::Migration[4.2]
  def change
    add_column :hosts, :pxe_loader, :string, :limit => 255
  end
end
