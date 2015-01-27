object @taxonomy

extends "api/v2/taxonomies/main"

attribute :ignore_types => :select_all_types

attributes :description, :created_at, :updated_at

child :users do
  extends "api/v2/users/base"
end

child :smart_proxies do
  extends "api/v2/smart_proxies/base"
end

child :subnets do
  extends "api/v2/subnets/base"
end

child :compute_resources do
  extends "api/v2/compute_resources/base"
end

child :media do
  extends "api/v2/media/base"
end

child :config_templates do
  extends "api/v2/config_templates/base"
end

child :domains do
  extends "api/v2/domains/base"
end

child :environments do
  extends "api/v2/environments/base"
end

child :hostgroups do
  extends "api/v2/hostgroups/base"
end

if @taxonomy.kind_of?(Location)
  child :organizations => :organizations  do
    extends "api/v2/taxonomies/base"
  end
end

if @taxonomy.kind_of?(Organization)
  child :locations => :locations do
    extends "api/v2/taxonomies/base"
  end
end

node do |taxonomy|
   { :parameters => partial("api/v2/parameters/base", :object => taxonomy.parameters) }
end