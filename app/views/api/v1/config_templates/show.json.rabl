object @config_template

attributes :name, :template, :snippet, :audit_comment, :id
node(:snippet) { |t| t.snippet? }

node do |template|
  unless template.snippet?
    glue :template_kind do
      attributes :name => :kind
    end
    child :template_combinations => :template_combinations do
      attributes :id, :environment_id, :hostgroup_id
    end
    child :operatingsystems do
      attributes :id
      node(:name) {|os| os.to_label}
    end
  end
end
