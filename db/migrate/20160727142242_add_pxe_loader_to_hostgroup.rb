class AddPxeLoaderToHostgroup < ActiveRecord::Migration[4.2]
  def change
    add_column :hostgroups, :pxe_loader, :string, :limit => 255

    reversible do |dir|
      dir.up do
        Hostgroup.update_all(:pxe_loader => 'PXELinux BIOS')
      end
    end
  end
end
