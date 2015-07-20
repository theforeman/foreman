object @hostgroup

attributes :name, :id, :subnet_id, :operatingsystem_id, :domain_id, :environment_id, :ancestry, :label, :parameters
node :puppetclass_ids do |hg|
  hg.puppetclasses.pluck(:id)
end
