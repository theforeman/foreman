class AddSubnetNameUniqueConstraint < ActiveRecord::Migration[5.1]
  def up
    merge_duplicate_subnets
    # we need to specify the lenght to make MySQL happy
    add_index :subnets, :name, :unique => true, length: { name: 255 }
  end

  def down
    remove_index :subnets, :name
  end

  private

  def merge_duplicate_subnets
    duplicate_names = Subnet.unscoped.select(:name).group(:name).having('count(name) > 1').pluck(:name)
    Rails.logger.info("Found #{duplicate_names} duplicate subnet names.")
    duplicate_names.each do |name|
      winner, *loosers = Subnet.unscoped.where(name: name)
      Rails.logger.info("Merging duplicate subnets with name '#{name}', " \
                        "keeping #{winner.id}, merging with #{loosers.map(&:id)}")
      Hostgroup.unscoped.where(:subnet_id => loosers.map(&:id)).update_all(:subnet_id => winner.id)
      Nic::Base.unscoped.where(:subnet_id => loosers.map(&:id)).update_all(:subnet_id => winner.id)
      SubnetParameter.unscoped.where(:reference_id => loosers.map(&:id)).update_all(:reference_id => winner.id)
      loosers.each(&:destroy!)
    end
  end
end
