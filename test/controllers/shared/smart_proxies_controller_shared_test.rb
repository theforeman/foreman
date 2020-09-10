module SmartProxiesControllerSharedTest
  extend ActiveSupport::Concern

  def setup_import_classes
    as_admin do
      Host::Managed.update_all(:environment_id => nil)
      Hostgroup.update_all(:environment_id => nil)
      HostClass.destroy_all
      HostgroupClass.destroy_all
      Puppetclass.destroy_all
      Environment.destroy_all
    end
    orgs = [taxonomies(:organization1)]
    locs = [taxonomies(:location1)]
    # This is the database status
    # and should result in a db_tree of {"env1" => ["a", "b", "c"], "env2" => ["a", "b", "c"]}
    as_admin do
      ["a", "b", "c"].each { |name| Puppetclass.create :name => name }
      ["env1", "env2"].each do |name|
        e = Environment.create!(:name => name, :organizations => orgs, :locations => locs)
        e.puppetclasses = Puppetclass.all
      end
    end
    # This is the on-disk status
    # and should result in a disk_tree of {"env1" => ["a", "b", "c"],"env2" => ["a", "b", "c"]}
    envs = HashWithIndifferentAccess.new(:env1 => %w{a b c}, :env2 => %w{a b c})
    pcs = [HashWithIndifferentAccess.new("a" => { "name" => "a", "module" => nil, "params" => {'key' => 'special'} })]
    classes = Hash[pcs.map { |k| [k.keys.first, Foreman::ImporterPuppetclass.new(k.values.first)] }]
    Environment.expects(:puppetEnvs).returns(envs).at_least(0)
    ProxyAPI::Puppet.any_instance.stubs(:environments).returns(["env1", "env2"])
    ProxyAPI::Puppet.any_instance.stubs(:classes).returns(classes)
  end
end
