class RenameSubnetNameToUnique < ActiveRecord::Migration[4.2]
  def up
    multiple_same_name = Subnet.unscoped.group(:name).count.delete_if { |name, value| value == 1 }
    multiple_same_name.each_key do |subnet_name|
      subnets_with_same_name = Subnet.where(:name => subnet_name)
      subnets_with_same_name.each_with_index do |subnet, index|
        new_name = Subnet.exists?(:name => "#{subnet.name}-#{index}") ? "#{subnet.name}-#{index}-#{SecureRandom.hex(2)}" : "#{subnet.name}-#{index}"
        subnet.update_attribute(:name, new_name)
      end
    end
  end
end
