object @config_template

attributes :name, :template, :snippet, :audit_comment, :id
node(:snippet) { |t| t.snippet? }

node do |config_template|
  unless config_template.snippet?
    child :template_kind do
      attributes :id, :name
    end
    child :template_combinations do
      attributes :environment_id, :hostgroup_id
    end
    child :operatingsystems do
      attributes :id
      node(:name) {|os| os.to_label}
    end
  end
end
