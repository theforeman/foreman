class AddProvisionMethodToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :provision_method, :string
    Host::Managed.unscoped.each do |h|
      h.update_attribute(:provision_method, h.capabilities.first)
    end
  end

  def self.down
    remove_column :hosts, :provision_method
  end
end
