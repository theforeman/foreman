object @hostgroup

extends "api/v2/hostgroups/main"

child :template_combinations do
  extends "api/v2/template_combinations/base"
end

root_object.facet_definitions.each do |definition|
  next unless definition.api_single_view
  node(false, if: ->(hostgroup) { definition.facet_record_for(hostgroup) }) do |hostgroup|
    partial(definition.api_single_view, object: hostgroup, locals: { facet: definition.facet_record_for(hostgroup) })
  end
end

node do |hostgroup|
  partial("api/v2/taxonomies/children_nodes", :object => hostgroup)
end
