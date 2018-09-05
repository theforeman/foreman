module Migrations
  # A migration class to ensure there are no subnets with duplicate name.
  # This is being used in 20180806151925_add_subnet_name_unique_constraint.rb
  # before introducing unique db constraint on the subnet.name
  class DeduplicateSubnets
    attr_reader :duplicate_names
    def initialize
      @duplicate_names = Subnet.unscoped.select(:name).group(:name).having('count(name) > 1').pluck(:name)
    end

    def run
      duplicate_names.each do |name|
        subnets = Subnet.unscoped.where(name: name)
        deduplicate_subnets(subnets)
      end
    end

    def deduplicate_subnets(subnets)
      name = subnets.first.name
      subnet_groups = group_identic_subnets(subnets)
      result_subnets = []
      suffix = 0
      subnet_groups.each do |subnet_group|
        if suffix == 0
          new_name = name
        else
          new_name = "#{name}-#{suffix}"
        end
        suffix = suggest_unique_suffix(name, suffix)
        result_subnets << merge_subnets(new_name, subnet_group)
      end
      result_subnets
    end

    def merge_subnets(new_name, subnets)
      winner, *loosers = subnets
      Rails.logger.info("Merging duplicate subnets with name '#{winner.name}', " \
                        "keeping #{winner.id}, merging with #{loosers.map(&:id)}, "\
                        "new name is '#{new_name}'")
      Hostgroup.unscoped.where(:subnet_id => loosers.map(&:id)).update_all(:subnet_id => winner.id)
      Nic::Base.unscoped.where(:subnet_id => loosers.map(&:id)).update_all(:subnet_id => winner.id)
      SubnetParameter.unscoped.where(:reference_id => loosers.map(&:id)).update_all(:reference_id => winner.id)
      Subnet.unscoped.where(id: loosers).destroy_all
      winner.update_attribute(:name, new_name)
      winner
    end

    def suggest_unique_suffix(name, current_suffix)
      new_suffix = current_suffix + 1
      new_suffix += 1 while Subnet.unscoped.where(name: "#{name}-#{new_suffix}").any?
      new_suffix
    end

    def group_identic_subnets(subnets)
      subnets.group_by do |subnet|
        attrs = subnet.attributes.except('id', 'created_at', 'updated_at')
        attrs.merge!(organization_ids: subnet.organization_ids,
                     location_ids: subnet.location_ids)
      end.values
    end
  end
end
