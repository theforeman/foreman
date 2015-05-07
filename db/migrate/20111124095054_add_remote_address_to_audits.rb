class AddRemoteAddressToAudits < ActiveRecord::Migration
  def up
    add_column :audits, :remote_address, :string
  end

  def down
    remove_column :audits, :remote_address
  end
end

