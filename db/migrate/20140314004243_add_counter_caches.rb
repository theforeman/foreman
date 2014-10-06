class AddCounterCaches < ActiveRecord::Migration
  def up
    # Architectures
    add_column :architectures, :hosts_count, :integer, :default => 0
    add_column :architectures, :hostgroups_count, :integer, :default => 0
    Architecture.all.each do |a|
      Architecture.reset_counters(a.id, :hosts)
      Architecture.reset_counters(a.id, :hostgroups)
    end

    # Domains
    add_column :domains, :hosts_count, :integer, :default => 0
    add_column :domains, :hostgroups_count, :integer, :default => 0
    Domain.all.each do |d|
      Domain.reset_counters(d.id, :hosts)
      Domain.reset_counters(d.id, :hostgroups)
    end

    # Environments
    add_column :environments, :hosts_count, :integer, :default => 0
    add_column :environments, :hostgroups_count, :integer, :default => 0
    Environment.all.each do |e|
      Environment.reset_counters(e.id, :hosts)
      Environment.reset_counters(e.id, :hostgroups)
    end

    # Hardware Models
    add_column :models, :hosts_count, :integer, :default => 0
    Model.all.each do |m|
      Model.reset_counters(m.id, :hosts)
    end

    # Operating Systems
    add_column :operatingsystems, :hosts_count, :integer, :default => 0
    add_column :operatingsystems, :hostgroups_count, :integer, :default => 0
    Operatingsystem.all.each do |o|
      Operatingsystem.reset_counters(o.id, :hosts)
      Operatingsystem.reset_counters(o.id, :hostgroups)
    end

    # Puppetclasses
    add_column :puppetclasses, :hosts_count, :integer, :default => 0
    add_column :puppetclasses, :hostgroups_count, :integer, :default => 0
    # On Rails 3.2.8, reset_counters doesn't work correctly for has_many :through
    # Seems to be something like https://github.com/rails/rails/issues/4293.
    # So set the intial counters with increment_counter instead:
    HostClass.all.each do |hc|
      Puppetclass.increment_counter(:hosts_count, hc.puppetclass_id)
    end

    HostgroupClass.all.each do |hgc|
      Puppetclass.increment_counter(:hostgroups_count, hgc.puppetclass_id)
    end

    add_column :puppetclasses, :lookup_keys_count, :integer, :default => 0
    EnvironmentClass.all.each do |e|
      Puppetclass.increment_counter(:lookup_keys_count, e.puppetclass_id) unless EnvironmentClass.used_by_other_environment_classes(e.lookup_key_id, e.id).count > 0
    end
  end

  def down
    remove_column :architectures,    :hosts_count
    remove_column :architectures,    :hostgroups_count

    remove_column :domains,          :hosts_count
    remove_column :domains,          :hostgroups_count

    remove_column :environments,     :hosts_count
    remove_column :environments,     :hostgroups_count

    remove_column :models,           :hosts_count

    remove_column :operatingsystems, :hosts_count
    remove_column :operatingsystems, :hostgroups_count

    remove_column :puppetclasses,    :hosts_count
    remove_column :puppetclasses,    :hostgroups_count
    remove_column :puppetclasses,    :lookup_keys_count
  end
end
