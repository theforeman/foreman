object @config_template

attributes :name, :template, :snippet, :audit_comment, :id

node do |ct|
  unless ct.template_kind.nil?
    child :template_kind do
      attributes :id, :name
    end
  else
    {:template_kind => nil}
  end
end

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
