object @config_template

attributes :id, :name, :template, :snippet, :audit_comment, :template_kind_id, :template_kind_name

child :template_combinations, :object_root => false do
  extends "api/v2/template_combinations/show"
end

child :operatingsystems, :object_root => false do
  attributes :id, :name
end
