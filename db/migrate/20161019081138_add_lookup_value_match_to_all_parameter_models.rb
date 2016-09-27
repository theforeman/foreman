class AddLookupValueMatchToAllParameterModels < ActiveRecord::Migration
  def up
    add_column :operatingsystems, :lookup_value_matcher, :string
    add_column :subnets, :lookup_value_matcher, :string
    add_column :domains, :lookup_value_matcher, :string
    add_column :taxonomies, :lookup_value_matcher, :string
    Operatingsystem.reset_column_information
    Subnet.reset_column_information
    Domain.reset_column_information
    Location.reset_column_information
    Organization.reset_column_information

    add_lookup_value_matcher_in_batches(Operatingsystem)
    add_lookup_value_matcher_in_batches(Domain)
    add_lookup_value_matcher_in_batches(Location)
    add_lookup_value_matcher_in_batches(Organization)
  end

  def add_lookup_value_matcher_in_batches(obj)
    obj.find_in_batches(:batch_size => 100) do |group|
      group.each do |item|
        item.update_attribute(:lookup_value_matcher, item.send(:lookup_value_match))
      end
    end
  end

  def down
    remove_column :operatingsystems, :lookup_value_matcher
    remove_column :subnets, :lookup_value_matcher
    remove_column :domains, :lookup_value_matcher
    remove_column :taxonomies, :lookup_value_matcher
  end
end
