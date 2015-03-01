class DeleteOrphanedRecords < ActiveRecord::Migration
  def up
    # DELETE ROW IF IT HAS AN ORPHANED FOREIGN KEY
    execute "DELETE FROM architectures_operatingsystems WHERE architecture_id NOT IN (SELECT id FROM architectures) OR operatingsystem_id NOT IN (SELECT id FROM operatingsystems)"
    execute "DELETE FROM config_templates_operatingsystems WHERE config_template_id NOT IN (SELECT id FROM config_templates) OR operatingsystem_id NOT IN (SELECT id FROM operatingsystems)"
    execute "DELETE FROM features_smart_proxies WHERE feature_id NOT IN (SELECT id FROM features) OR smart_proxy_id NOT IN (SELECT id FROM smart_proxies)"
    execute "DELETE FROM features_smart_proxies WHERE feature_id NOT IN (SELECT id FROM features) OR smart_proxy_id NOT IN (SELECT id FROM smart_proxies)"
    execute "DELETE FROM media_operatingsystems WHERE medium_id NOT IN (SELECT id FROM media) OR operatingsystem_id NOT IN (SELECT id FROM operatingsystems)"
    execute "DELETE FROM operatingsystems_ptables WHERE ptable_id NOT IN (SELECT id FROM ptables) OR operatingsystem_id NOT IN (SELECT id FROM operatingsystems)"
    execute "DELETE FROM operatingsystems_puppetclasses WHERE puppetclass_id NOT IN (SELECT id FROM puppetclasses) OR operatingsystem_id NOT IN (SELECT id FROM operatingsystems)"
    execute "DELETE FROM subnet_domains WHERE domain_id NOT IN (SELECT id FROM domains) OR subnet_id NOT IN (SELECT id FROM subnets)"
    execute "DELETE FROM user_compute_resources WHERE compute_resource_id NOT IN (SELECT id FROM compute_resources) OR user_id NOT IN (SELECT id FROM users)"
    execute "DELETE FROM user_domains WHERE domain_id NOT IN (SELECT id FROM domains) OR user_id NOT IN (SELECT id FROM users)"
    execute "DELETE FROM user_facts WHERE fact_name_id NOT IN (SELECT id FROM fact_names) OR user_id NOT IN (SELECT id FROM users)"
    execute "DELETE FROM user_hostgroups WHERE hostgroup_id NOT IN (SELECT id FROM hostgroups) OR user_id NOT IN (SELECT id FROM users)"
    execute "DELETE FROM user_roles WHERE role_id NOT IN (SELECT id FROM roles) OR user_id NOT IN (SELECT id FROM users)"
    KeyPair.where("compute_resource_id NOT IN (?)", ComputeResource.pluck(:id)).delete_all
    LookupKey.where("puppetclass_id NOT IN (?)", Puppetclass.pluck(:id)).delete_all
    execute "DELETE FROM environment_classes WHERE environment_id NOT IN (SELECT id FROM environments) OR lookup_key_id NOT IN (SELECT id FROM lookup_keys) OR puppetclass_id NOT IN (SELECT id FROM puppetclasses)"
    LookupValue.where("lookup_key_id NOT IN (?)", LookupKey.pluck(:id)).delete_all
    FactValue.where("fact_name_id NOT IN (?) OR host_id NOT IN (?)", FactName.pluck(:id), Host::Base.pluck(:id)).delete_all
    TaxableTaxonomy.where("taxonomy_id NOT IN (?)", Taxonomy.unscoped.pluck(:id)).delete_all
    HostClass.where("host_id NOT IN (?) OR puppetclass_id NOT IN (?)", Host::Base.pluck(:id), Puppetclass.pluck(:id)).delete_all
    # .unscoped is needed since the default scope orders by title, but title is not a db field yet.
    HostgroupClass.where("hostgroup_id NOT IN (?) OR puppetclass_id NOT IN (?)", Hostgroup.unscoped.pluck(:id), Puppetclass.pluck(:id)).delete_all
    Report.where("host_id NOT IN (?)", Host::Base.pluck(:id)).delete_all
    Log.where("message_id NOT IN (?) OR report_id NOT IN (?) OR source_id NOT IN (?)", Message.pluck(:id), Report.pluck(:id), Source.pluck(:id)).delete_all
    Token.where("host_id NOT IN (?)", Host::Base.pluck(:id)).delete_all
    TrendCounter.where("trend_id NOT IN (?)", Trend.pluck(:id)).delete_all

    # NULLIFY FOREIGN KEY VALUE IF IT HAS AN ORPHANED FOREIGN KEY
    Audit.unscoped.where("user_id NOT IN (?)", User.pluck(:id)).update_all(:user_id => nil)
    ConfigTemplate.where("template_kind_id NOT IN (?)", TemplateKind.pluck(:id)).update_all(:template_kind_id => nil)
    Domain.where("dns_id NOT IN (?)", SmartProxy.pluck(:id)).update_all(:dns_id => nil)
    Subnet.where("dhcp_id NOT IN (?)", SmartProxy.pluck(:id)).update_all(:dhcp_id => nil)
    Subnet.where("dns_id NOT IN (?)", SmartProxy.pluck(:id)).update_all(:dns_id => nil)
    Subnet.where("tftp_id NOT IN (?)", SmartProxy.pluck(:id)).update_all(:tftp_id => nil)
    Image.where("architecture_id NOT IN (?)", Architecture.pluck(:id)).update_all(:architecture_id => nil)
    Image.where("compute_resource_id NOT IN (?)", ComputeResource.pluck(:id)).update_all(:compute_resource_id => nil)
    Image.where("operatingsystem_id NOT IN (?)", Operatingsystem.unscoped.pluck(:id)).update_all(:operatingsystem_id => nil)
    Nic::Base.where("domain_id NOT IN (?)", Domain.pluck(:id)).update_all(:domain_id => nil)
    Nic::Base.where("host_id NOT IN (?)", Host::Base.pluck(:id)).update_all(:host_id => nil)
    Nic::Base.where("subnet_id NOT IN (?)", Subnet.pluck(:id)).update_all(:subnet_id => nil)
    OsDefaultTemplate.where("config_template_id NOT IN (?)", ConfigTemplate.pluck(:id)).update_all(:config_template_id => nil)
    OsDefaultTemplate.where("operatingsystem_id NOT IN (?)", Operatingsystem.unscoped.pluck(:id)).update_all(:operatingsystem_id => nil)
    OsDefaultTemplate.where("template_kind_id NOT IN (?)", TemplateKind.pluck(:id)).update_all(:template_kind_id => nil)
    TemplateCombination.where("config_template_id NOT IN (?)", ConfigTemplate.pluck(:id)).update_all(:config_template_id => nil)
    TemplateCombination.where("environment_id NOT IN (?)", Environment.pluck(:id)).update_all(:environment_id => nil)
    TemplateCombination.where("hostgroup_id NOT IN (?)", Hostgroup.unscoped.pluck(:id)).update_all(:hostgroup_id => nil)

    host_groups_up
    hosts_up
  end

  def down
  end

  private

  def host_groups_up
    Hostgroup.unscoped.where("architecture_id NOT IN (?)", Architecture.pluck(:id)).update_all(:architecture_id => nil)
    Hostgroup.unscoped.where("domain_id NOT IN (?)", Domain.pluck(:id)).update_all(:domain_id => nil)
    Hostgroup.unscoped.where("environment_id NOT IN (?)", Environment.pluck(:id)).update_all(:environment_id => nil)
    Hostgroup.unscoped.where("medium_id NOT IN (?)", Medium.pluck(:id)).update_all(:medium_id => nil)
    Hostgroup.unscoped.where("operatingsystem_id NOT IN (?)", Operatingsystem.unscoped.pluck(:id)).update_all(:operatingsystem_id => nil)
    Hostgroup.unscoped.where("ptable_id NOT IN (?)", Ptable.pluck(:id)).update_all(:ptable_id => nil)
    Hostgroup.unscoped.where("puppet_ca_proxy_id NOT IN (?)", SmartProxy.pluck(:id)).update_all(:puppet_ca_proxy_id => nil)
    Hostgroup.unscoped.where("puppet_proxy_id NOT IN (?)", SmartProxy.pluck(:id)).update_all(:puppet_proxy_id => nil)
    Hostgroup.unscoped.where("subnet_id NOT IN (?)", Subnet.pluck(:id)).update_all(:subnet_id => nil)
  end

  def hosts_up
    Host::Base.where("architecture_id NOT IN (?)", Architecture.pluck(:id)).update_all(:architecture_id => nil)
    Host::Base.where("domain_id NOT IN (?)", Domain.pluck(:id)).update_all(:domain_id => nil)
    Host::Base.where("environment_id NOT IN (?)", Environment.pluck(:id)).update_all(:environment_id => nil)
    Host::Base.where("medium_id NOT IN (?)", Medium.pluck(:id)).update_all(:medium_id => nil)
    Host::Base.where("operatingsystem_id NOT IN (?)", Operatingsystem.unscoped.pluck(:id)).update_all(:operatingsystem_id => nil)
    Host::Base.where("ptable_id NOT IN (?)", Ptable.pluck(:id)).update_all(:ptable_id => nil)
    Host::Base.where("puppet_ca_proxy_id NOT IN (?)", SmartProxy.pluck(:id)).update_all(:puppet_ca_proxy_id => nil)
    Host::Base.where("puppet_proxy_id NOT IN (?)", SmartProxy.pluck(:id)).update_all(:puppet_proxy_id => nil)
    Host::Base.where("subnet_id NOT IN (?)", Subnet.pluck(:id)).update_all(:subnet_id => nil)
    Host::Base.where("compute_resource_id NOT IN (?)", ComputeResource.pluck(:id)).update_all(:compute_resource_id => nil)
    Host::Base.where("hostgroup_id NOT IN (?)", Hostgroup.unscoped.pluck(:id)).update_all(:hostgroup_id => nil)
    Host::Base.where("image_id NOT IN (?)", Image.pluck(:id)).update_all(:image_id => nil)
    Host::Base.where("model_id NOT IN (?)", Model.pluck(:id)).update_all(:model_id => nil)
    Host::Base.where("location_id NOT IN (?)", Location.unscoped.pluck(:id)).update_all(:location_id => nil)
    Host::Base.where("organization_id NOT IN (?)", Organization.unscoped.pluck(:id)).update_all(:organization_id => nil)
  end
end
