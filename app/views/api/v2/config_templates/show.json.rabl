object @config_template

attributes :name, :template, :snippet, :audit_comment, :id, :template_kind_id, :operatingsystem_ids

node do |ct|
  unless ct.template_combinations.empty?
    child :template_combinations do
      extends "api/v2/template_combinations/show"
    end
  else
    {:template_combinations => []}
  end
end

