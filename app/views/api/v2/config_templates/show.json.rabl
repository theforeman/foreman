object @config_template

attributes :id, :name, :template, :snippet, :audit_comment, :template_kind_id, :template_kind_name

node do |ct|
  unless ct.template_combinations.empty?
    child :template_combinations do
      extends "api/v2/template_combinations/show"
    end
  else
    {:template_combinations => []}
  end
end

node do |ct|
  unless ct.operatingsystems.empty?
    child :operatingsystems do
      attributes :id, :name
    end
  else
    {:operatingsystems => []}
  end
end
