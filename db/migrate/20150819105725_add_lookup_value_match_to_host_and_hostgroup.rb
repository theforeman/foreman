class AddLookupValueMatchToHostAndHostgroup < ActiveRecord::Migration
  def up
    add_column :hosts, :lookup_value_matcher, :string
    add_column :hostgroups, :lookup_value_matcher, :string
    Host::Managed.reset_column_information
    Hostgroup.reset_column_information

    Host::Managed.where(:type => 'Host::Managed').find_in_batches(:batch_size => 100) do |group|
      group.each do |host|
        host.update_attribute(:lookup_value_matcher, host.send(:lookup_value_match))
      end
    end

    Hostgroup.find_in_batches(:batch_size => 100) do |group|
      group.each do |hostgroup|
        hostgroup.update_attribute(:lookup_value_matcher, hostgroup.send(:lookup_value_match))
      end
    end
  end

  def down
    remove_column :hosts, :lookup_value_matcher
    remove_column :hostgroups, :lookup_value_matcher
  end
end
