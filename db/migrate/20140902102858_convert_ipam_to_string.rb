class ConvertIpamToString < ActiveRecord::Migration[4.2]
  class FakeSubnet < ApplicationRecord
    self.table_name = 'subnets'
  end

  def up
    add_column :subnets, :ipam_tmp, :string, :default => ::IPAM::MODES[:dhcp], :null => false, :limit => 255
    FakeSubnet.reset_column_information
    FakeSubnet.all.each do |subnet|
      if subnet.ipam
        subnet.ipam_tmp = ::IPAM::MODES[:dhcp]
      else
        subnet.ipam_tmp = ::IPAM::MODES[:none]
      end
      subnet.save!
    end
    remove_column :subnets, :ipam
    rename_column :subnets, :ipam_tmp, :ipam
  end

  def down
    add_column :subnets, :ipam_tmp, :boolean, :default => true, :null => false
    FakeSubnet.reset_column_information
    FakeSubnet.all.each do |subnet|
      subnet.ipam_tmp = subnet.ipam != ::IPAM::MODES[:none]
      subnet.save!
    end
    remove_column :subnets, :ipam
    rename_column :subnets, :ipam_tmp, :ipam
  end
end
