class AddLookupValueMatchToHostAndHostgroup < ActiveRecord::Migration[4.2]
  def up
    add_column :hosts, :lookup_value_matcher, :string, :limit => 255
    add_column :hostgroups, :lookup_value_matcher, :string, :limit => 255
    Host::Managed.reset_column_information
    Hostgroup.reset_column_information

    matchers = LookupValue.where("lookup_values.match like ?", "fqdn=%").distinct.pluck('lookup_values.match')
    fqdns = matchers.map { |m| m.gsub(/^fqdn=/, "") }
    hostnames = fqdns.map { |fqdn| fqdn.split(".").first }

    if SETTINGS[:unattended]
      hosts = Host::Managed.where(:nics => {:name => (fqdns + hostnames)}).joins(:primary_interface)
    else
      fact_name_id = FactName.where(:name => "fqdn").first.try(:id)
      hosts = Host::Managed.joins(:fact_values).where(:fact_values => {:fact_name_id => fact_name_id, :value => (fqdns + hostnames)}) if fact_name_id.present?
    end

    if hosts.present?
      hosts = hosts.readonly(false).distinct

      hosts.each do |host|
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
