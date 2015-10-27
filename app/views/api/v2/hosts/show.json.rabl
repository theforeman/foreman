object @host

extends "api/v2/hosts/main"

child :host_parameters => :parameters do
  extends "api/v2/parameters/base"
end

node do |host|
  { :all_parameters => partial("api/v2/parameters/base", :object => host.host_inherited_params_objects) }
end

child :interfaces => :interfaces do
  extends "api/v2/interfaces/base"
end

child :puppetclasses do
  extends "api/v2/puppetclasses/base"
end

node do |host|
  { :all_puppetclasses => partial("api/v2/puppetclasses/base", :object => host.all_puppetclasses) }
end

child :config_groups do
  extends "api/v2/config_groups/main"
end

host_additional_tabs(@host).each do |id, tab|
  if tab.is_a? String
    node do |host|
      partial "api/v2/#{tab}", :object => host
    end
  else
    child tab => id.to_sym do |aspect|
      class_name = tab.class.name.underscore
      extends "api/v2/#{class_name.pluralize}/base"
    end
  end
end
