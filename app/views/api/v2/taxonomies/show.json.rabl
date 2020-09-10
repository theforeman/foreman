object @taxonomy

extends "api/v2/taxonomies/main"

attribute :ignore_types => :select_all_types

attributes :description, :created_at, :updated_at

ancestors = @taxonomy.ancestors.preload(
  :users, :smart_proxies, :subnets, :compute_resources, :media, :ptables,
  :provisioning_templates, :domains, :realms, :environments, :hostgroups
)
node :hosts_count do |taxonomy|
  hosts_count[taxonomy]
end

child (@taxonomy.users + ancestors.map(&:users).flatten).uniq => :users do
  extends "api/v2/users/base"
  node :inherited do |user|
    !@taxonomy.users.include?(user)
  end
end

child (@taxonomy.smart_proxies + ancestors.map(&:smart_proxies).flatten).uniq => :smart_proxies do
  extends "api/v2/smart_proxies/base"
  node :inherited do |smart_proxy|
    !@taxonomy.smart_proxies.include?(smart_proxy)
  end
end

child (@taxonomy.subnets + ancestors.map(&:subnets).flatten).uniq => :subnets do
  extends "api/v2/subnets/base"
  node :inherited do |subnet|
    !@taxonomy.subnets.include?(subnet)
  end
end

child (@taxonomy.compute_resources + ancestors.map(&:compute_resources).flatten).uniq => :compute_resources do
  extends "api/v2/compute_resources/base"
  node :inherited do |compute_resource|
    !@taxonomy.compute_resources.include?(compute_resource)
  end
end

child (@taxonomy.media + ancestors.map(&:media).flatten).uniq => :media do
  extends "api/v2/media/base"
  node :inherited do |current_media|
    !@taxonomy.media.include?(current_media)
  end
end

child (@taxonomy.ptables + ancestors.map(&:ptables).flatten).uniq => :ptables do
  extends "api/v2/ptables/main"
  node :inherited do |ptable|
    !@taxonomy.ptables.include?(ptable)
  end
end

child (@taxonomy.provisioning_templates + ancestors.map(&:provisioning_templates).flatten).uniq => :provisioning_templates do
  extends "api/v2/provisioning_templates/base"
  node :inherited do |provisioning_template|
    !@taxonomy.provisioning_templates.include?(provisioning_template)
  end
end

child (@taxonomy.domains + ancestors.map(&:domains).flatten).uniq => :domains do
  extends "api/v2/domains/base"
  node :inherited do |domain|
    !@taxonomy.domains.include?(domain)
  end
end

child (@taxonomy.realms + ancestors.map(&:realms).flatten).uniq => :realms do
  extends "api/v2/realms/base"
  node :inherited do |realm|
    !@taxonomy.realms.include?(realm)
  end
end

child (@taxonomy.environments + ancestors.map(&:environments).flatten).uniq => :environments do
  extends "api/v2/environments/base"
  node :inherited do |environment|
    !@taxonomy.environments.include?(environment)
  end
end

child (@taxonomy.hostgroups + ancestors.map(&:hostgroups).flatten).uniq => :hostgroups do
  extends "api/v2/hostgroups/base"
  node :inherited do |hostgroup|
    !@taxonomy.hostgroups.include?(hostgroup)
  end
end

if @taxonomy.is_a?(Location)
  child :organizations => :organizations do
    extends "api/v2/taxonomies/base"
  end
end

if @taxonomy.is_a?(Organization)
  child :locations => :locations do
    extends "api/v2/taxonomies/base"
  end
end

node do |taxonomy|
  { :parameters => partial("api/v2/parameters/index", :object => taxonomy.params_objects) }
end
