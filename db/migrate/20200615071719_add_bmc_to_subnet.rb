class AddBmcToSubnet < ActiveRecord::Migration[6.0]
  def change
    add_column :subnets, :bmc_id, :integer

    reversible do |dir|
      dir.up do
        Subnet.unscoped.each do |subnet|
          candidate = subnet.proxies.find { |subnet_proxy| subnet_proxy.has_feature?('BMC') }
          candidate ||= SmartProxy.unscoped.with_features("BMC").first
          subnet.bmc = candidate
          subnet.save!(validate: false)
        end
      end
    end
  end
end
