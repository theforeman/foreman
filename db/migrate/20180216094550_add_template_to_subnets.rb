class AddTemplateToSubnets < ActiveRecord::Migration[5.1]
  def change
    add_column :subnets, :template_id, :integer

    reversible do |dir|
      dir.up do
        Subnet.unscoped.find_each do |subnet|
          proxy = subnet.tftp
          next if proxy.blank?
          subnet.template = proxy if proxy.has_feature?("TFTP")
          subnet.save
        end
      end
    end
  end
end
