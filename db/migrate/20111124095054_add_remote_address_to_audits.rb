class AddRemoteAddressToAudits < ActiveRecord::Migration[4.2]
  def up
    add_column :audits, :remote_address, :string, :limit => 255
  end

  def down
    remove_column :audits, :remote_address
  end
end
